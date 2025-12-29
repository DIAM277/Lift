import 'package:flutter/material.dart';

/// 详情页面顶部概览卡片
/// 支持自定义颜色、图标、统计项
class DetailHeaderCard extends StatelessWidget {
  /// 卡片主色调（用于渐变）
  final Color? primaryColor;

  /// 顶部图标
  final IconData icon;

  /// 顶部类型文字（如"训练记录"、"动作组合"）
  final String typeLabel;

  /// 额外的类型信息（如日期）
  final String? typeInfo;

  /// 标题（可编辑）
  final String title;

  /// 是否处于编辑模式
  final bool isEditing;

  /// 标题输入框控制器
  final TextEditingController? titleController;

  /// 标题改变回调
  final ValueChanged<String>? onTitleChanged;

  /// 统计项列表
  final List<DetailStatItem> stats;

  const DetailHeaderCard({
    super.key,
    this.primaryColor, // ✅ 改为可选参数
    required this.icon,
    required this.typeLabel,
    this.typeInfo,
    required this.title,
    this.isEditing = false,
    this.titleController,
    this.onTitleChanged,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ✅ 使用传入的颜色或主题主色
    final cardPrimaryColor = primaryColor ?? colorScheme.primary;

    // 计算次要颜色（更亮）
    final secondaryColor = Color.lerp(cardPrimaryColor, Colors.white, 0.2)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardPrimaryColor, secondaryColor], // ✅ 使用动态颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardPrimaryColor.withOpacity(0.3), // ✅ 使用动态颜色
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部状态栏
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (typeInfo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          typeInfo!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 主要内容区域
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: theme.cardColor, // ✅ 使用主题卡片色
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题 - 可编辑
                if (isEditing && titleController != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: titleController,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "输入名称",
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: onTitleChanged,
                    ),
                  )
                else
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                    ),
                  ),

                const SizedBox(height: 16),

                // 统计信息
                Row(
                  children: stats.map((stat) {
                    return Expanded(
                      child: _buildStatColumn(
                        stat.icon,
                        stat.value,
                        stat.label,
                        stat.color,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

/// 统计项数据类
class DetailStatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const DetailStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
