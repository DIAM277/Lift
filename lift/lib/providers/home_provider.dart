import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../data/models/workout.dart';

part 'home_provider.g.dart'; // 等待生成

// 获取所有训练记录(按照时间倒序)
@riverpod
Future<List<WorkoutSession>> recentWorkouts(RecentWorkoutsRef ref) async {
  final isar = await IsarService().db;
  // 查询WorkoutSession表，按照startTime倒序，取前10条数据
  return await isar.workoutSessions
      .where()
      .sortByStartTimeDesc()
      .limit(10)
      .findAll();
}

// 计算本周统计数据
@riverpod
Future<Map<String, dynamic>> weeklyStats(WeeklyStatsRef ref) async {
  final isar = await IsarService().db;

  // 获取本周一点的零点时间
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeek = DateTime(monday.year, monday.month, monday.day);

  // 查询本周之后的所有训练
  final workouts = await isar.workoutSessions
      .filter()
      .startTimeGreaterThan(startOfWeek)
      .findAll();

  // 计算总容量
  double totalVolume = 0;
  for (var w in workouts) {
    totalVolume += w.totalVolume;
  }

  return {'count': workouts.length, 'totalVolume': totalVolume.toInt()};
}
