import 'package:flutter/material.dart';

class MuscleGroupService {
  // 肌肉部位定义
  static const Map<String, MuscleGroup> muscleGroups = {
    'chest': MuscleGroup('胸部', '💪', Color(0xFFFF6B6B)),
    'back': MuscleGroup('背部', '🦾', Color(0xFF4ECDC4)),
    'shoulders': MuscleGroup('肩部', '💪', Color(0xFFFFBE0B)),
    'arms': MuscleGroup('手臂', '💪', Color(0xFF95E1D3)),
    'legs': MuscleGroup('腿部', '🦵', Color(0xFF9B59B6)),
    'core': MuscleGroup('核心', '🔥', Color(0xFFE74C3C)),
    'cardio': MuscleGroup('有氧', '❤️', Color(0xFFE91E63)),
    'unknown': MuscleGroup('未知', '❓', Color(0xFF95A5A6)),
  };

  // 关键词映射
  static const Map<String, List<String>> keywords = {
    'chest': [
      '胸',
      '卧推',
      '推胸',
      '飞鸟',
      '夹胸',
      'bench press',
      'chest',
      'press',
      '哑铃推胸',
      '杠铃卧推',
      '上斜',
      '下斜',
      '平板',
      '龙门架夹胸',
      '俯卧撑',
    ],
    'back': [
      '背',
      '引体',
      '划船',
      '硬拉',
      '下拉',
      'pull',
      'row',
      'deadlift',
      'back',
      '高位下拉',
      '坐姿划船',
      '俯身',
      '杠铃划船',
      '哑铃划船',
      '反向飞鸟',
    ],
    'shoulders': [
      '肩',
      '推举',
      '侧平举',
      '前平举',
      '飞鸟',
      'shoulder',
      'press',
      'raise',
      '肩推',
      '哑铃推举',
      '杠铃推举',
      '阿诺德',
      '侧平',
      '前平',
      '后束',
    ],
    'arms': [
      '臂',
      '弯举',
      '二头',
      '三头',
      '臂屈伸',
      'curl',
      'tricep',
      'bicep',
      'arm',
      '杠铃弯举',
      '哑铃弯举',
      '锤式',
      '集中',
      '臂屈',
      '颈后',
      '下压',
    ],
    'legs': [
      '腿',
      '深蹲',
      '腿举',
      '腿弯举',
      '腿屈伸',
      '弓步',
      'squat',
      'leg',
      'lunge',
      '史密斯深蹲',
      '箭步蹲',
      '腿推',
      '坐姿腿屈伸',
      '俯卧腿弯举',
      '提踵',
    ],
    'core': [
      '腹',
      '卷腹',
      '核心',
      '平板支撑',
      '仰卧起坐',
      'core',
      'abs',
      'plank',
      '悬垂举腿',
      '腹肌轮',
      '俄罗斯转体',
      '侧支撑',
      '山羊挺身',
    ],
    'cardio': [
      '跑步',
      '骑行',
      '游泳',
      '跳绳',
      '椭圆机',
      '划船机',
      'run',
      'cardio',
      '慢跑',
      '快走',
      '爬楼',
      '有氧',
      '单车',
      'bike',
      'swim',
    ],
  };

  /// 根据动作名称自动识别部位
  static String detectMuscleGroup(String exerciseName) {
    if (exerciseName.isEmpty) return 'unknown';

    final name = exerciseName.toLowerCase();

    // 遍历所有关键词进行匹配
    for (var entry in keywords.entries) {
      for (var keyword in entry.value) {
        if (name.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return 'unknown';
  }

  /// 获取部位信息
  static MuscleGroup getMuscleGroup(String key) {
    return muscleGroups[key] ?? muscleGroups['unknown']!;
  }

  /// 获取所有可选部位（用于手动选择）
  static List<MapEntry<String, MuscleGroup>> getAllGroups() {
    return muscleGroups.entries.where((e) => e.key != 'unknown').toList();
  }
}

/// 肌肉部位模型
class MuscleGroup {
  final String name;
  final String emoji;
  final Color color;

  const MuscleGroup(this.name, this.emoji, this.color);
}
