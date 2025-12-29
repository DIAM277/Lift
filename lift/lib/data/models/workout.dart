import 'package:isar/isar.dart';

part 'workout.g.dart';

// 训练日(顶层模型)
@Collection()
class WorkoutSession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime startTime; // 训练日期

  DateTime? endTime; // 训练结束时间

  String? note; // 训练备注

  double totalVolume = 0; // 总训练量 = 重量 * 次数

  int duration = 0; // 训练时长

  // 状态字段：planned | completed
  String status = 'planned';

  // 训练动作列表,存放具体的动作组
  List<WorkoutSessionLog> exercises = []; // 训练动作列表
}

// 某次训练中的一个动作记录 (嵌入式对象)
@embedded
class WorkoutSessionLog {
  // 此处存储动作的ID和名字(快照)
  // 不直接存Exercise对象，避免数据冗余和同步问题
  // 存储ID方便点击跳转到动作详情，存储名字方便展示
  int? exerciseId;
  String? exerciseName;
   String? targetPart = 'unknown';

  // 记录动作组数
  List<WorkoutSet> sets = [];
}

// 具体的每一组数据(eg. 卧推 100kg x 8)
@embedded
class WorkoutSet {
  int index = 0; // 组序号，从0开始

  double weight = 0; // 使用重量

  int reps = 0; // 次数

  bool isCompleted = false; // 是否完成该组(勾选状态)

  int? feeling; // 组感觉评分，1-10分
}
