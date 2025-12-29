import 'package:flutter/material.dart';
import '../../data/models/workout.dart';
import '../../data/models/routine.dart';
import '../../services/muscle_group_service.dart';

/// 通用的动作卡片组件
class ExerciseCard<T> extends StatefulWidget {
  final int index;
  final T exercise;
  final bool isEditable;
  final VoidCallback onRemove;
  final VoidCallback? onChanged;
  final bool showBodyweightToggle;
  final bool showVolume;

  const ExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.isEditable,
    required this.onRemove,
    this.onChanged,
    this.showBodyweightToggle = false,
    this.showVolume = true,
  });

  @override
  State<ExerciseCard<T>> createState() => _ExerciseCardState<T>();
}

class _ExerciseCardState<T> extends State<ExerciseCard<T>> {
  bool _localIsBodyweight = false;

  // 获取动作名称
  String get exerciseName {
    final ex = widget.exercise;
    if (ex is WorkoutSessionLog) {
      return ex.exerciseName ?? "未命名动作";
    } else if (ex is RoutineExercise) {
      return ex.exerciseName ?? "未命名动作";
    }
    return "未命名动作";
  }

  // 设置动作名称
  set exerciseName(String value) {
    final ex = widget.exercise;
    if (ex is WorkoutSessionLog) {
      ex.exerciseName = value;
      // 自动识别部位（仅当部位为空或未知时）
      if (ex.targetPart == null ||
          ex.targetPart!.isEmpty ||
          ex.targetPart == 'unknown') {
        ex.targetPart = MuscleGroupService.detectMuscleGroup(value);
      }
    } else if (ex is RoutineExercise) {
      ex.exerciseName = value;
      if (ex.targetPart == null ||
          ex.targetPart!.isEmpty ||
          ex.targetPart == 'unknown') {
        ex.targetPart = MuscleGroupService.detectMuscleGroup(value);
      }
    }
    widget.onChanged?.call();
  }

  // 获取训练部位
  String get targetPart {
    final ex = widget.exercise;
    if (ex is WorkoutSessionLog) {
      return ex.targetPart ?? 'unknown';
    } else if (ex is RoutineExercise) {
      return ex.targetPart ?? 'unknown';
    }
    return 'unknown';
  }

  // 设置训练部位
  set targetPart(String value) {
    final ex = widget.exercise;
    if (ex is WorkoutSessionLog) {
      ex.targetPart = value;
    } else if (ex is RoutineExercise) {
      ex.targetPart = value;
    }
    setState(() {});
    widget.onChanged?.call();
  }

  // 获取训练组列表
  List<dynamic> get sets {
    final ex = widget.exercise;
    if (ex is WorkoutSessionLog) {
      return ex.sets;
    } else if (ex is RoutineExercise) {
      return ex.sets;
    }
    return [];
  }

  // 是否为自重训练
  bool get isBodyweight {
    final ex = widget.exercise;
    if (ex is RoutineExercise) {
      return ex.isBodyweight;
    }
    return _localIsBodyweight;
  }

  // 设置自重状态
  void setBodyweight(bool value) {
    final ex = widget.exercise;
    if (ex is RoutineExercise) {
      ex.isBodyweight = value;
      if (value) {
        for (var set in ex.sets) {
          set.weight = 0;
        }
      }
    } else {
      _localIsBodyweight = value;
      if (value) {
        for (var set in sets) {
          set.weight = 0.0;
        }
      }
    }
    widget.onChanged?.call();
  }

  // 计算总容量
  double _calculateVolume() {
    double total = 0;
    for (var set in sets) {
      final weight = set.weight as double;
      final reps = set.reps as int;
      total += weight * reps;
    }
    return total;
  }

  // 美观的部位选择器
  void _showMuscleGroupPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MuscleGroupSelector(
        currentSelection: targetPart,
        onSelected: (key) {
          targetPart = key;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroup = MuscleGroupService.getMuscleGroup(targetPart);
    final isUnknown = targetPart == 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ✅ 动作名称（限制最大宽度）
                    Flexible(
                      flex: 3,
                      child: widget.isEditable
                          ? _ExerciseNameInput(
                              initialValue: exerciseName,
                              onChanged: (value) {
                                setState(() {
                                  exerciseName = value;
                                });
                              },
                            )
                          : Text(
                              exerciseName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    const SizedBox(width: 8),

                    // ✅ 部位标签（显示文字）
                    GestureDetector(
                      onTap: widget.isEditable ? _showMuscleGroupPicker : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUnknown
                              ? Colors.orange.withOpacity(0.1)
                              : muscleGroup.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isUnknown
                                ? Colors.orange.withOpacity(0.5)
                                : muscleGroup.color.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              muscleGroup.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              muscleGroup.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isUnknown
                                    ? Colors.orange
                                    : muscleGroup.color,
                              ),
                            ),
                            if (widget.isEditable) ...[
                              const SizedBox(width: 2),
                              Icon(
                                Icons.edit,
                                size: 10,
                                color: isUnknown
                                    ? Colors.orange
                                    : muscleGroup.color,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 自重/负重切换按钮
                    if (widget.showBodyweightToggle && widget.isEditable) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            setBodyweight(!isBodyweight);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isBodyweight
                                ? const Color(0xFF4F75FF).withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isBodyweight
                                  ? const Color(0xFF4F75FF).withOpacity(0.5)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isBodyweight
                                    ? Icons.accessibility_new
                                    : Icons.fitness_center,
                                size: 12,
                                color: isBodyweight
                                    ? const Color(0xFF4F75FF)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isBodyweight ? "自重" : "负重",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isBodyweight
                                      ? const Color(0xFF4F75FF)
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // 删除按钮
                    if (widget.isEditable) ...[
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: widget.onRemove,
                      ),
                    ],
                  ],
                ),

                // 总容量显示
                if (widget.showVolume) ...[
                  const SizedBox(height: 4),
                  Text(
                    "总容量: ${_calculateVolume().toInt()}kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),

          // ...existing code... (组列表部分保持不变)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                // 表头
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        "组数",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isBodyweight ? "类型" : "重量(kg)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "次数",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.showVolume)
                      SizedBox(
                        width: 60,
                        child: Text(
                          "容量(kg)",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (widget.isEditable) const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 6),

                // 组列表
                ...sets.asMap().entries.map((setEntry) {
                  if (widget.isEditable) {
                    return _SetRowInput(
                      key: ValueKey('${widget.index}_${setEntry.key}'),
                      index: setEntry.key,
                      set: setEntry.value,
                      isBodyweight: isBodyweight,
                      showVolume: widget.showVolume,
                      onRemove: () {
                        setState(() {
                          sets.removeAt(setEntry.key);
                        });
                        widget.onChanged?.call();
                      },
                      onChanged: () {
                        setState(() {});
                        widget.onChanged?.call();
                      },
                    );
                  } else {
                    return _buildSetRowDisplay(setEntry.key, setEntry.value);
                  }
                }),

                // 添加组按钮
                if (widget.isEditable) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          double w = 20;
                          int r = 12;
                          if (sets.isNotEmpty) {
                            w = sets.last.weight;
                            r = sets.last.reps;
                          }
                          if (isBodyweight) {
                            w = 0;
                          }
                          final ex = widget.exercise;
                          if (ex is WorkoutSessionLog) {
                            ex.sets.add(
                              WorkoutSet()
                                ..weight = w
                                ..reps = r
                                ..isCompleted = false,
                            );
                          } else if (ex is RoutineExercise) {
                            ex.sets.add(
                              RoutineSet()
                                ..weight = w
                                ..reps = r,
                            );
                          }
                        });
                        widget.onChanged?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F75FF),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("添加组", style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRowDisplay(int index, dynamic set) {
    final weight = set.weight as double;
    final reps = set.reps as int;
    final volume = (weight * reps).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              weight.toStringAsFixed(1).replaceAll(".0", ""),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              reps.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          if (widget.showVolume)
            SizedBox(
              width: 60,
              child: Text(
                volume.toString(),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F75FF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ✅ 美观的部位选择器（底部弹窗）
class _MuscleGroupSelector extends StatelessWidget {
  final String currentSelection;
  final ValueChanged<String> onSelected;

  const _MuscleGroupSelector({
    required this.currentSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                const Text(
                  "选择训练部位",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // 部位网格
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: MuscleGroupService.getAllGroups().map((entry) {
                final isSelected = currentSelection == entry.key;
                final group = entry.value;

                return InkWell(
                  onTap: () => onSelected(entry.key),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? group.color.withOpacity(0.15)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? group.color : Colors.grey[200]!,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                group.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? group.color
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: group.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 动作名称输入组件
class _ExerciseNameInput extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _ExerciseNameInput({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_ExerciseNameInput> createState() => _ExerciseNameInputState();
}

class _ExerciseNameInputState extends State<_ExerciseNameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "输入动作名称",
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

// 组输入行组件（保持不变）
class _SetRowInput extends StatefulWidget {
  final int index;
  final dynamic set;
  final bool isBodyweight;
  final bool showVolume;
  final VoidCallback onRemove;
  final VoidCallback? onChanged;

  const _SetRowInput({
    super.key,
    required this.index,
    required this.set,
    required this.isBodyweight,
    required this.showVolume,
    required this.onRemove,
    this.onChanged,
  });

  @override
  State<_SetRowInput> createState() => _SetRowInputState();
}

class _SetRowInputState extends State<_SetRowInput> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    final weight = widget.set.weight as double;
    final reps = widget.set.reps as int;
    _weightCtrl = TextEditingController(
      text: weight.toStringAsFixed(1).replaceAll(".0", ""),
    );
    _repsCtrl = TextEditingController(text: reps.toString());
  }

  @override
  void didUpdateWidget(covariant _SetRowInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBodyweight != oldWidget.isBodyweight) {
      if (widget.isBodyweight) {
        _weightCtrl.text = "0";
        widget.set.weight = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "${widget.index + 1}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isBodyweight
                  ? const Center(
                      child: Text(
                        "自重",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        widget.set.weight = double.tryParse(val) ?? 0.0;
                        widget.onChanged?.call();
                      },
                    ),
            ),
          ),
          Expanded(
            child: Container(
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  widget.set.reps = int.tryParse(val) ?? 0;
                  widget.onChanged?.call();
                },
              ),
            ),
          ),
          if (widget.showVolume)
            SizedBox(
              width: 60,
              child: Text(
                "${(widget.set.weight * widget.set.reps).toInt()}",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F75FF),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
