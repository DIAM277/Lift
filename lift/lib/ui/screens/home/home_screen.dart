import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../workout/workout_session_screen.dart';
import '../calendar/add_plan_screen.dart';
import '../workout/workout_history_screen.dart';
import '../workout/plan_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WorkoutSession? _todayPlan;
  List<WorkoutSession> _recentSessions = [];
  List<WorkoutSession> _allWeekSessions = [];
  List<WorkoutSession> _allMonthSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = await IsarService().db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final todayPlans = await isar.workoutSessions
        .filter()
        .startTimeBetween(today, tomorrow)
        .statusEqualTo('planned')
        .findAll();

    final recentCompleted = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .sortByStartTimeDesc()
        .limit(5)
        .findAll();

    final monthStart = DateTime(now.year, now.month, 1);
    final allMonthSessions = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .startTimeGreaterThan(monthStart)
        .findAll();

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final allWeekSessions = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .startTimeGreaterThan(weekStartDate)
        .findAll();

    setState(() {
      _todayPlan = todayPlans.isNotEmpty ? todayPlans.first : null;
      _recentSessions = recentCompleted;
      _allWeekSessions = allWeekSessions;
      _allMonthSessions = allMonthSessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary, // ✅ 使用主题主色
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeHeader(theme),
              const SizedBox(height: 24),
              _buildTodayTrainingCard(colorScheme),
              const SizedBox(height: 20),
              _buildQuickStats(theme, colorScheme),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      "近5次训练",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                      ),
                    ),
                  ),
                  if (_recentSessions.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text(
                        "查看所有记录",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary, // ✅ 使用主题主色
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecentSessions(theme, colorScheme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "早上好";
    } else if (hour < 18) {
      greeting = "下午好";
    } else {
      greeting = "晚上好";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "准备好锻炼了吗？",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTrainingCard(ColorScheme colorScheme) {
    final hasPlan = _todayPlan != null;

    return InkWell(
      onTap: () async {
        if (hasPlan) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailScreen(sessionId: _todayPlan!.id),
            ),
          );
          if (result == true) {
            _loadData();
          }
        } else {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPlanScreen(selectedDate: today),
            ),
          );
          if (result == true) {
            _loadData();
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasPlan
                ? [colorScheme.primary, colorScheme.secondary] // ✅ 使用主题颜色
                : [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFF8E53),
                  ], // 无计划时保持红色
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (hasPlan ? colorScheme.primary : const Color(0xFFFF6B6B))
                  .withOpacity(0.3), // ✅ 使用主题主色
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasPlan ? Icons.calendar_today : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "今日训练",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasPlan ? "点击开始" : "点击创建",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasPlan) ...[
              Text(
                _todayPlan!.note ?? "训练计划",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildPlanBadge(
                    Icons.fitness_center,
                    "${_todayPlan!.exercises.length} 个动作",
                  ),
                  const SizedBox(width: 8),
                  _buildPlanBadge(Icons.timer, "约 ${_estimateDuration()} 分钟"),
                ],
              ),
            ] else ...[
              const Text(
                "今天还没有训练计划",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "点击卡片立即创建今天的训练计划",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildEmptyPlanBadge(Icons.fitness_center, "选择动作"),
                  const SizedBox(width: 8),
                  _buildEmptyPlanBadge(Icons.schedule, "设置计划"),
                  const SizedBox(width: 8),
                  _buildEmptyPlanBadge(Icons.play_arrow, "开始训练"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlanBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _estimateDuration() {
    if (_todayPlan == null) return "0";
    return (_todayPlan!.exercises.length * 10).toString();
  }

  Widget _buildQuickStats(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryScreen(
                    filterType: 'week',
                    title: '本周训练记录',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: _buildStatCard(
              Icons.calendar_month,
              _getThisWeekStats(),
              "本周训练",
              Colors.orange,
              theme,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryScreen(
                    filterType: 'month',
                    title: '本月训练记录',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: _buildStatCard(
              Icons.local_fire_department,
              _getThisMonthStats(),
              "本月训练",
              Colors.red,
              theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Map<String, int> stats,
    String label,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("${stats['days']}", "天", color),
              Container(width: 1, height: 30, color: Colors.grey[200]),
              _buildStatItem("${stats['times']}", "次", color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Map<String, int> _getThisWeekStats() {
    final uniqueDays = _allWeekSessions
        .map((s) {
          final date = s.startTime;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .length;

    return {'days': uniqueDays, 'times': _allWeekSessions.length};
  }

  Map<String, int> _getThisMonthStats() {
    final uniqueDays = _allMonthSessions
        .map((s) {
          final date = s.startTime;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .length;

    return {'days': uniqueDays, 'times': _allMonthSessions.length};
  }

  Widget _buildRecentSessions(ThemeData theme, ColorScheme colorScheme) {
    if (_recentSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor, // ✅ 使用主题卡片色
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "还没有训练记录",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentSessions.map((session) {
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
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
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
      }).toList(),
    );
  }
}
