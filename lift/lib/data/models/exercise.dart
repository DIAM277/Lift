import 'package:isar/isar.dart';

part 'exercise.g.dart';

@Collection()
class Exercise {

  Id id = Isar.autoIncrement;

  // 动作名称，如"卧推"
  late String name;

  // 动作目标部位，如"胸部"
  late String targetPart;

  // 索引字段
  @Index()
  bool isCutom = false; // 是否是自定义动作

  // 默认休息时间，单位秒s
  int defaultRestTime = 90;
}