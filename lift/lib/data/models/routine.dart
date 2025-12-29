import 'package:isar/isar.dart';

part 'routine.g.dart'; // 等待生成

@collection
class WorkoutRoutine {
  Id id = Isar.autoIncrement;

  late String name; // 组合名称，如 "胸部训练 A"

  // 这个组合里包含哪些动作？
  List<RoutineExercise> exercises = [];

  String? description;
}

// 组合里的某个动作（预设模版）
@embedded
class RoutineExercise {
  String? exerciseName; // 动作名称，如 "卧推"
  String? targetPart = 'unknown';
  bool isBodyweight = false; // 是否为自重动作

  // 预设的组数据
  List<RoutineSet> sets = [];
}

// 预设的组（只存目标值）
@embedded
class RoutineSet {
  double weight = 0; // 预设重量
  int reps = 0; // 预设次数
}
