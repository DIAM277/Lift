import '../data/models/workout.dart';
import '../services/muscle_group_service.dart';

class StatisticsService {
  /// 计算累计训练天数（去重）
  static int calculateTotalDays(List<WorkoutSession> sessions) {
    final uniqueDays = <String>{};
    for (var session in sessions) {
      final dateKey =
          '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      uniqueDays.add(dateKey);
    }
    return uniqueDays.length;
  }

  /// 计算累计训练总容量
  static double calculateTotalVolume(List<WorkoutSession> sessions) {
    return sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );
  }

  /// 计算累计训练时长（分钟）
  static int calculateTotalDuration(List<WorkoutSession> sessions) {
    return sessions.fold<int>(0, (sum, session) => sum + session.duration);
  }

  /// 计算解锁动作数量（去重）
  static int calculateUniqueExercises(List<WorkoutSession> sessions) {
    final uniqueExercises = <String>{};
    for (var session in sessions) {
      for (var exercise in session.exercises) {
        if (exercise.exerciseName != null &&
            exercise.exerciseName!.isNotEmpty) {
          uniqueExercises.add(exercise.exerciseName!);
        }
      }
    }
    return uniqueExercises.length;
  }

  /// 获取月度训练次数趋势
  static Map<String, int> getMonthlyWorkoutTrend(
    List<WorkoutSession> sessions,
    int months,
  ) {
    final now = DateTime.now();
    final result = <String, int>{};

    // 初始化最近N个月的数据
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      result[key] = 0;
    }

    // 统计每个月的训练次数
    for (var session in sessions) {
      final key =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        result[key] = (result[key] ?? 0) + 1;
      }
    }

    return result;
  }

  /// 获取月度训练容量趋势
  static Map<String, double> getMonthlyVolumeTrend(
    List<WorkoutSession> sessions,
    int months,
  ) {
    final now = DateTime.now();
    final result = <String, double>{};

    // 初始化
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      result[key] = 0;
    }

    // 统计
    for (var session in sessions) {
      final key =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        result[key] = (result[key] ?? 0) + session.totalVolume;
      }
    }

    return result;
  }

  /// 获取周训练频率分布
  static Map<String, int> getWeeklyFrequency(List<WorkoutSession> sessions) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final result = <String, int>{};

    for (var day in weekdays) {
      result[day] = 0;
    }

    for (var session in sessions) {
      final weekday = session.startTime.weekday; // 1=Monday, 7=Sunday
      final dayName = weekdays[weekday - 1];
      result[dayName] = (result[dayName] ?? 0) + 1;
    }

    return result;
  }

  /// 获取各部位训练占比
  static Map<String, int> getMuscleGroupDistribution(
    List<WorkoutSession> sessions,
  ) {
    final distribution = <String, int>{};

    for (var session in sessions) {
      for (var exercise in session.exercises) {
        final part = exercise.targetPart ?? 'unknown';
        distribution[part] = (distribution[part] ?? 0) + 1;
      }
    }

    return distribution;
  }

  /// 获取动作使用频率 Top 5
  static List<MapEntry<String, int>> getTopExercises(
    List<WorkoutSession> sessions,
    int top,
  ) {
    final exerciseCount = <String, int>{};

    for (var session in sessions) {
      for (var exercise in session.exercises) {
        final name = exercise.exerciseName ?? '未命名';
        exerciseCount[name] = (exerciseCount[name] ?? 0) + 1;
      }
    }

    final sorted = exerciseCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(top).toList();
  }
}
