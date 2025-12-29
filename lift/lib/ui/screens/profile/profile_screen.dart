import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:lift/ui/screens/profile/export_data_screen.dart';
import 'package:lift/ui/screens/profile/statistics_screen.dart';
import 'package:lift/ui/screens/profile/theme_setting_screen.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../../../data/models/routine.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalWorkouts = 0;
  int _totalDays = 0;
  double _totalVolume = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final isar = await IsarService().db;

    // 获取所有已完成的训练
    final completedSessions = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .findAll();

    // 计算统计数据
    final totalWorkouts = completedSessions.length;
    final totalVolume = completedSessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );

    // 计算训练天数（去重）
    final uniqueDays = <String>{};
    for (var session in completedSessions) {
      final dateKey =
          '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      uniqueDays.add(dateKey);
    }

    setState(() {
      _totalWorkouts = totalWorkouts;
      _totalVolume = totalVolume;
      _totalDays = uniqueDays.length;
      _isLoading = false;
    });
  }

  // 删除所有数据的方法
  Future<void> _deleteAllData() async {
    final isar = await IsarService().db;
    
    await isar.writeTxn(() async {
      // 删除所有训练记录
      await isar.workoutSessions.clear();
      // 删除所有动作组合
      await isar.workoutRoutines.clear();
    });

    // 重新加载统计数据
    await _loadStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有数据已删除'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              "危险操作",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "确定要删除所有数据吗？",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "此操作将删除：\n• 所有训练记录\n• 所有训练计划\n• 所有动作组合",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              "⚠️ 此操作无法撤销！",
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "确认删除",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,  // ✅ 使用主题背景色
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 页面标题
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 24),
                child: Text(
                  "我的",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.displayLarge?.color,  // ✅ 使用主题文字色
                  ),
                ),
              ),

              // 用户信息卡片
              _buildUserInfoCard(theme, colorScheme),
              const SizedBox(height: 20),

              // 训练统计卡片
              _buildStatsCard(theme, colorScheme),
              const SizedBox(height: 20),

              // 功能菜单
              _buildMenuSection(
                "数据管理",
                [
                  _MenuItem(
                    icon: Icons.cloud_upload,
                    title: "备份数据",
                    subtitle: "将数据备份到云端",
                    onTap: () {
                      _showComingSoonDialog("备份数据");
                    },
                  ),
                  _MenuItem(
                    icon: Icons.cloud_download,
                    title: "恢复数据",
                    subtitle: "从云端恢复数据",
                    onTap: () {
                      _showComingSoonDialog("恢复数据");
                    },
                  ),
                  _MenuItem(
                    icon: Icons.file_download,
                    title: "导出数据",
                    subtitle: "导出为CSV或JSON",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExportDataScreen(),
                        ),
                      );
                    },
                  ),
                ],
                theme,
                colorScheme,
              ),

              const SizedBox(height: 16),

              _buildMenuSection(
                "应用设置",
                [
                  _MenuItem(
                    icon: Icons.palette,
                    title: "主题设置",
                    subtitle: "自定义应用外观",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.notifications,
                    title: "通知设置",
                    subtitle: "管理训练提醒",
                    onTap: () {
                      _showComingSoonDialog("通知设置");
                    },
                  ),
                  _MenuItem(
                    icon: Icons.language,
                    title: "语言设置",
                    subtitle: "切换应用语言",
                    onTap: () {
                      _showComingSoonDialog("语言设置");
                    },
                  ),
                ],
                theme,
                colorScheme,
              ),

              const SizedBox(height: 16),

              _buildMenuSection(
                "关于",
                [
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: "关于应用",
                    subtitle: "版本 1.0.0",
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: "隐私政策",
                    subtitle: "查看隐私条款",
                    onTap: () {
                      _showComingSoonDialog("隐私政策");
                    },
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: "帮助与反馈",
                    subtitle: "获取帮助或提出建议",
                    onTap: () {
                      _showComingSoonDialog("帮助与反馈");
                    },
                  ),
                ],
                theme,
                colorScheme,
              ),

              const SizedBox(height: 16),

              // 开发者测试区域
              _buildMenuSection(
                "🚧 开发者选项",
                [
                  _MenuItem(
                    icon: Icons.delete_forever,
                    title: "删除所有数据",
                    subtitle: "⚠️ 仅供开发测试使用",
                    onTap: _showDeleteConfirmDialog,
                  ),
                ],
                theme,
                colorScheme,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 用户信息卡片 - 使用主题颜色
  Widget _buildUserInfoCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,      // ✅ 使用主题主色
            colorScheme.secondary,    // ✅ 使用主题次色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),  // ✅ 使用主题主色
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "健身爱好者",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "坚持训练，成就更好的自己",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            onPressed: () {
              _showComingSoonDialog("编辑资料");
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ✅ 统计卡片 - 使用主题颜色
  Widget _buildStatsCard(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,  // ✅ 使用主题卡片色
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,  // ✅ 使用主题主色
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,  // ✅ 使用主题卡片色
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),  // ✅ 使用主题主色
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: colorScheme.primary,  // ✅ 使用主题主色
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "训练统计",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,  // ✅ 使用主题文字色
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.fitness_center,
                  "$_totalWorkouts",
                  "总训练次数",
                  colorScheme.primary,  // ✅ 使用主题主色
                ),
                _buildStatItem(
                  Icons.calendar_today,
                  "$_totalDays",
                  "训练天数",
                  Colors.orange,
                ),
                _buildStatItem(
                  Icons.monitor_weight,
                  "${(_totalVolume / 1000).toStringAsFixed(1)}",
                  "总容量(吨)",
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ✅ 菜单区域 - 使用主题颜色
  Widget _buildMenuSection(
    String title,
    List<_MenuItem> items,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,  // ✅ 使用主题文字色
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,  // ✅ 使用主题卡片色
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildMenuItem(item, theme, colorScheme),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: theme.dividerColor,  // ✅ 使用主题分割线色
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ✅ 菜单项 - 使用主题颜色
  Widget _buildMenuItem(
    _MenuItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),  // ✅ 使用主题主色
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: colorScheme.primary,  // ✅ 使用主题主色
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,  // ✅ 使用主题文字色
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "敬请期待",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("$feature 功能正在开发中，敬请期待！"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "关于 Lift",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("版本: 1.0.0"),
            SizedBox(height: 8),
            Text("一款简洁高效的健身记录应用"),
            SizedBox(height: 8),
            Text("帮助你更好地追踪训练进度"),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}