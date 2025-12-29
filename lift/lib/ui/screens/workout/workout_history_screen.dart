import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import 'plan_detail_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final String? filterType; // 'week', 'month', or null for all
  final String? title;

  const WorkoutHistoryScreen({super.key, this.filterType, this.title});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<WorkoutSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = await IsarService().db;

    DateTime? startDate;
    final now = DateTime.now();

    // 根据过滤类型设置起始时间
    if (widget.filterType == 'week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (widget.filterType == 'month') {
      startDate = DateTime(now.year, now.month, 1);
    }

    List<WorkoutSession> sessions;
    if (startDate != null) {
      sessions = await isar.workoutSessions
          .filter()
          .statusEqualTo('completed')
          .startTimeGreaterThan(startDate)
          .sortByStartTimeDesc()
          .findAll();
    } else {
      sessions = await isar.workoutSessions
          .filter()
          .statusEqualTo('completed')
          .sortByStartTimeDesc()
          .findAll();
    }

    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
      appBar: AppBar(
        title: Text(widget.title ?? '训练记录'),
        backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary, // ✅ 使用主题主色
              ),
            )
          : _sessions.isEmpty
          ? _buildEmptyState(theme)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsCard(colorScheme),
                  const SizedBox(height: 20),
                  ..._sessions.map(
                    (session) => _buildSessionCard(session, theme, colorScheme),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(ColorScheme colorScheme) {
    final totalSessions = _sessions.length;
    final totalVolume = _sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );
    final totalDuration = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    // 计算训练天数（去重）
    final uniqueDays = _sessions
        .map((s) {
          final date = s.startTime;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary], // ✅ 使用主题颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3), // ✅ 使用主题主色
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('训练天数', '$uniqueDays', '天'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem('训练次数', '$totalSessions', '次'),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总容量', '${totalVolume.toInt()}', 'kg'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem('总时长', '$totalDuration', '分钟'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    String emptyText;
    if (widget.filterType == 'week') {
      emptyText = '本周还没有训练记录';
    } else if (widget.filterType == 'month') {
      emptyText = '本月还没有训练记录';
    } else {
      emptyText = '还没有训练记录';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            emptyText,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    WorkoutSession session,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ 使用主题卡片色
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ),
        title: Text(
          session.note ?? "训练",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('MM月dd日 HH:mm', 'zh_CN').format(session.startTime),
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${session.totalVolume.toInt()}kg",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // ✅ 使用主题主色
              ),
            ),
            Text(
              "${session.duration}分钟",
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailScreen(sessionId: session.id),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
      ),
    );
  }
}
