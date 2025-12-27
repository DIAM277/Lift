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
  bool isCustom = false; // 是否是自定义动作

  // 默认休息时间，单位秒s
  int defaultRestTime = 90;

  // TODO：关于动作可以有更多字段：比如其类型：器械/徒手，有氧/无氧等
}