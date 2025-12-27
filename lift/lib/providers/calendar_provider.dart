import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../data/models/workout.dart';
import '../data/models/routine.dart';

part 'calendar_provider.g.dart';

// 获取某个月的所有训练记录
@riverpod
Future<List<WorkoutSession>> monthlyWorkouts(
  MonthlyWorkoutsRef ref,
  DateTime month,
) async {
  final isar = await IsarService().db;

  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  return await isar.workoutSessions
      .filter()
      .startTimeBetween(startOfMonth, endOfMonth)
      .findAll();
}

// 获取某一天的所有训练记录
@riverpod
Future<List<WorkoutSession>> dailyWorkouts(
  DailyWorkoutsRef ref,
  DateTime day,
) async {
  final isar = await IsarService().db;

  final startOfDay = DateTime(day.year, day.month, day.day);
  final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

  return await isar.workoutSessions
      .filter()
      .startTimeBetween(startOfDay, endOfDay)
      .sortByStartTime()
      .findAll();
}

// 从 Routine 创建训练计划
@riverpod
Future<WorkoutSession> createPlanFromRoutine(
  CreatePlanFromRoutineRef ref,
  WorkoutRoutine routine,
  DateTime date,
  String? note,
) async {
  final isar = await IsarService().db;

  // 深拷贝 Routine 数据到 WorkoutSession
  final session = WorkoutSession()
    ..startTime = date
    ..status = 'planned'
    ..note = note ?? routine.name
    ..exercises = routine.exercises.map((routineEx) {
      return WorkoutSessionLog()
        ..exerciseName = routineEx.exerciseName
        ..targetPart =
            '' // 可以从 Exercise 表查询补充
        ..sets = routineEx.sets.map((routineSet) {
          return WorkoutSet()
            ..weight = routineSet.weight
            ..reps = routineSet.reps
            ..isCompleted = false;
        }).toList();
    }).toList();

  await isar.writeTxn(() async {
    await isar.workoutSessions.put(session);
  });

  return session;
}
