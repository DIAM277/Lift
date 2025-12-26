import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_provider.dart';
import '../../data/models/workout.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听数据
    final statsAsync = ref.watch(weeklyStatsProvider);
    final recentAsync = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '健身记录',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: [
          // 此处可以存放头像
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 本周训练统计卡片
            _buildWeeklySummaryCard(statsAsync),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.fitness_center,
                    color: Colors.blueAccent,
                    title: '今日训练',
                    subtitle: '暂无计划',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.calendar_today,
                    color: Colors.orangeAccent,
                    title: '日历回顾',
                    subtitle: '${DateTime.now().month}月',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 最近训练标题
            const Text(
              '最近训练',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 最近训练列表
            recentAsync.when(
              data: (workouts) {
                if (workouts.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: workouts.map((w) => _buildWorkoutCard(w)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('加载失败: $err')),
            ),
            // 底部留白，防止遮挡
            const SizedBox(height: 80),
          ],
        ),
      ),
      // 底部大按钮：创建训练日
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO:跳转到新建训练日界面
              print('创建训练日');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F75FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "新建训练日",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 拆分UI组件 ---
  Widget _buildWeeklySummaryCard(AsyncValue<Map<String, dynamic>> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("本周训练", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              statsAsync.when(
                data: (data) => Text(
                  "${data['count']} 次",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                loading: () =>
                    const Text("- 次", style: TextStyle(fontSize: 32)),
                error: (_, __) => const Text("Error"),
              ),
              statsAsync.when(
                data: (data) => Text(
                  "总容量: ${data['volume'] ?? 0}kg",
                  style: TextStyle(color: Colors.grey[500]),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutSession session) {
    // 格式化日期：2025-12-26
    final dateStr = DateFormat('yyyy-MM-dd').format(session.startTime);
    // 格式化时长：45min (如果没有结束时间，计算当前时间差)
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime).inMinutes
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题 (如果 Note 为空，暂时显示日期 + 默认文字)
                Text(
                  session.note ?? "$dateStr 训练",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "容量: ${session.totalVolume.toInt()}kg | 时长: ${duration}min",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "还没有训练记录\n快开始第一次训练吧！",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
