import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../data/isar_service.dart';
import '../../data/models/workout.dart';
import 'workout_session_screen.dart';
import 'add_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WorkoutSession? _todayPlan;
  List<WorkoutSession> _recentSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = await IsarService().db;
    final now = DateTime.now();
    // 修复：使用准确的今天开始和结束时间
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // 查找今天的训练计划
    final todayPlans = await isar.workoutSessions
        .filter()
        .startTimeBetween(today, tomorrow)
        .statusEqualTo('planned')
        .findAll();

    // 查找最近的训练记录（已完成的）
    final recentCompleted = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .sortByStartTimeDesc()
        .limit(5)
        .findAll();

    setState(() {
      _todayPlan = todayPlans.isNotEmpty ? todayPlans.first : null;
      _recentSessions = recentCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 欢迎标题
              _buildWelcomeHeader(),
              const SizedBox(height: 24),

              // 今日训练卡片
              _buildTodayTrainingCard(),
              const SizedBox(height: 20),

              // 快速统计
              _buildQuickStats(),
              const SizedBox(height: 20),

              // 最近训练记录
              _buildRecentSessions(),

              // 底部留出空间给按钮
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _handleStartWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F75FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: Icon(
              _todayPlan != null ? Icons.play_arrow : Icons.add,
              color: Colors.white,
              size: 28,
            ),
            label: Text(
              _todayPlan != null ? "开始训练" : "创建今日计划",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
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
        const Text(
          "准备好锻炼了吗？",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTodayTrainingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _todayPlan != null
              ? [const Color(0xFF4F75FF), const Color(0xFF6B8FFF)]
              : [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (_todayPlan != null
                        ? const Color(0xFF4F75FF)
                        : Colors.grey[400]!)
                    .withOpacity(0.3),
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
                child: const Icon(
                  Icons.calendar_today,
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
            ],
          ),
          const SizedBox(height: 16),
          if (_todayPlan != null) ...[
            Text(
              _todayPlan!.note ?? "训练计划",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${_todayPlan!.exercises.length} 个动作",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPlanBadge(
                  Icons.fitness_center,
                  "${_todayPlan!.exercises.length}",
                ),
                const SizedBox(width: 8),
                _buildPlanBadge(Icons.timer, "~${_estimateDuration()}分钟"),
              ],
            ),
          ] else ...[
            const Text(
              "今天还没有训练计划",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "点击下方按钮创建今天的训练计划吧",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
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
          const SizedBox(width: 4),
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

  String _estimateDuration() {
    if (_todayPlan == null) return "0";
    // 简单估算：每个动作约10分钟
    return (_todayPlan!.exercises.length * 10).toString();
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.calendar_month,
            "${_getThisWeekCount()}",
            "本周训练",
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.local_fire_department,
            "${_getThisMonthCount()}",
            "本月训练",
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _recentSessions.where((s) => s.startTime.isAfter(weekStart)).length;
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _recentSessions.where((s) => s.startTime.isAfter(monthStart)).length;
  }

  Widget _buildRecentSessions() {
    if (_recentSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "最近训练",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...(_recentSessions.take(3).map((session) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F75FF),
                    ),
                  ),
                  Text(
                    "${session.duration}分钟",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  void _handleStartWorkout() async {
    if (_todayPlan != null) {
      // 有计划，开始训练
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSessionScreen(sessionId: _todayPlan!.id),
        ),
      );

      // 训练完成后刷新数据
      if (result == true) {
        _loadData();
      }
    } else {
      // 没有计划，跳转到添加计划页面
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPlanScreen(selectedDate: today),
        ),
      );

      // 添加计划后刷新数据
      if (result == true) {
        _loadData();
      }
    }
  }
}
