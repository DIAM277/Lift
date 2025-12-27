import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../data/models/exercise.dart';

part 'exercise_provider.g.dart';

// 首次启动，若没有动作，自动插入预设动作
// 获取所有动作
@riverpod
Future<List<Exercise>> allExercises(AllExercisesRef ref) async {
  final isar = await IsarService().db;
  return await isar.exercises.where().findAll();
}

@riverpod
Future<void> seedExercises(SeedExercisesRef ref) async {
  final isar = await IsarService().db;
  final count = await isar.exercises.count();

  // TODO: 可以考虑把预设动作放到一个 JSON 文件里，然后读取
  if (count == 0) {
    final presets = [
      // --------------- 胸部 ---------------
      Exercise()
        ..name = "标准俯卧撑"
        ..targetPart = "胸部"
        ..isCustom = false,
      Exercise()
        ..name = "上斜俯卧撑"
        ..targetPart = "胸部"
        ..isCustom = false,
      Exercise()
        ..name = "下斜俯卧撑"
        ..targetPart = "胸部"
        ..isCustom = false,
      Exercise()
        ..name = "卧推"
        ..targetPart = "胸部"
        ..isCustom = false,
      Exercise()
        ..name = "龙门架夹胸"
        ..targetPart = "胸部"
        ..isCustom = false,
      Exercise()
        ..name = "双杠臂屈伸"
        ..targetPart = "胸部"
        ..isCustom = false,

      // --------------- 背部 ---------------
      Exercise()
        ..name = "引体向上"
        ..targetPart = "背部"
        ..isCustom = false,
      Exercise()
        ..name = "高位下拉"
        ..targetPart = "背部"
        ..isCustom = false,
      Exercise()
        ..name = "俯身划船"
        ..targetPart = "背部"
        ..isCustom = false,
      Exercise()
        ..name = "坐姿划船"
        ..targetPart = "背部"
        ..isCustom = false,
      Exercise()
        ..name = "硬拉"
        ..targetPart = "背部"
        ..isCustom = false,

      // --------------- 肩部 ---------------
      Exercise()
        ..name = "哑铃推举"
        ..targetPart = "肩部"
        ..isCustom = false,
      Exercise()
        ..name = "侧平举"
        ..targetPart = "肩部"
        ..isCustom = false,
      Exercise()
        ..name = "前平举"
        ..targetPart = "肩部"
        ..isCustom = false,
      Exercise()
        ..name = "俯身飞鸟"
        ..targetPart = "肩部"
        ..isCustom = false,
      Exercise()
        ..name = "面拉"
        ..targetPart = "肩部"
        ..isCustom = false,

      // --------------- 腿部 ---------------
      Exercise()
        ..name = "深蹲"
        ..targetPart = "腿部"
        ..isCustom = false,
      Exercise()
        ..name = "箭步蹲"
        ..targetPart = "腿部"
        ..isCustom = false,
      Exercise()
        ..name = "腿举"
        ..targetPart = "腿部"
        ..isCustom = false,
      Exercise()
        ..name = "腿弯举"
        ..targetPart = "腿部"
        ..isCustom = false,
      Exercise()
        ..name = "提踵"
        ..targetPart = "腿部"
        ..isCustom = false,

      // --------------- 手臂 ---------------
      Exercise()
        ..name = "弯举"
        ..targetPart = "手臂"
        ..isCustom = false,
      Exercise()
        ..name = "锤式弯举"
        ..targetPart = "手臂"
        ..isCustom = false,
      Exercise()
        ..name = "颈后臂屈伸"
        ..targetPart = "手臂"
        ..isCustom = false,
      Exercise()
        ..name = "绳索下压"
        ..targetPart = "手臂"
        ..isCustom = false,

      // --------------- 核心 ---------------
      Exercise()
        ..name = "平板支撑"
        ..targetPart = "核心"
        ..isCustom = false,
      Exercise()
        ..name = "卷腹"
        ..targetPart = "核心"
        ..isCustom = false,
      Exercise()
        ..name = "俄罗斯转体"
        ..targetPart = "核心"
        ..isCustom = false,
      Exercise()
        ..name = "举腿"
        ..targetPart = "核心"
        ..isCustom = false,
    ];

    await isar.writeTxn(() async {
      await isar.exercises.putAll(presets);
    });
  }
}
