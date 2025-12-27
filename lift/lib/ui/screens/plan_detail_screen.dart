import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/workout.dart';
import '../../data/isar_service.dart';

class PlanDetailScreen extends StatefulWidget {
  final int sessionId;

  const PlanDetailScreen({super.key, required this.sessionId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  WorkoutSession? _session;
  bool _isEditing = false;
  bool _isLoading = true;
  late TextEditingController _noteController; // 计划名称控制器

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadSession();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // 从数据库加载最新数据
  Future<void> _loadSession() async {
    final isar = await IsarService().db;
    final session = await isar.workoutSessions.get(widget.sessionId);

    if (session != null) {
      setState(() {
        _session = _deepCopySession(session);
        _noteController.text = _session!.note ?? "";
        _isLoading = false;
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // 深拷贝 WorkoutSession
  WorkoutSession _deepCopySession(WorkoutSession original) {
    final copy = WorkoutSession()
      ..id = original.id
      ..startTime = original.startTime
      ..endTime = original.endTime
      ..note = original.note
      ..totalVolume = original.totalVolume
      ..duration = original.duration
      ..status = original.status
      ..exercises = original.exercises.map((exercise) {
        return WorkoutSessionLog()
          ..exerciseName = exercise.exerciseName
          ..targetPart = exercise.targetPart
          ..sets = exercise.sets.map((set) {
            return WorkoutSet()
              ..weight = set.weight
              ..reps = set.reps
              ..isCompleted = set.isCompleted;
          }).toList();
      }).toList();

    return copy;
  }

  // 计算单个动作的总容量
  double _calculateExerciseVolume(WorkoutSessionLog exercise) {
    double total = 0;
    for (var set in exercise.sets) {
      total += set.weight * set.reps;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("加载中..."),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dateStr = DateFormat(
      'yyyy年MM月dd日',
      'zh_CN',
    ).format(_session!.startTime);
    final isPlanned = _session!.status == 'planned';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isPlanned ? "训练计划" : "训练记录",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isPlanned)
            TextButton(
              onPressed: () {
                if (_isEditing) {
                  _updatePlan();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              child: Text(
                _isEditing ? "保存" : "编辑",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // 头部信息卡片
          Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPlanned
                            ? Colors.orangeAccent.withOpacity(0.1)
                            : const Color(0xFF4F75FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPlanned ? Icons.schedule : Icons.check_circle,
                        color: isPlanned
                            ? Colors.orangeAccent
                            : const Color(0xFF4F75FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 计划名称 - 可编辑
                if (_isEditing && isPlanned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "输入计划名称",
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _session!.note = value;
                      },
                    ),
                  )
                else
                  Text(
                    _session!.note ?? "无备注",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                if (!isPlanned) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.fitness_center,
                        "${_session!.totalVolume.toInt()}kg",
                        "总容量",
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        Icons.timer_outlined,
                        "${_session!.duration}min",
                        "时长",
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 动作列表
          ..._session!.exercises.asMap().entries.map((entry) {
            return _buildExerciseCard(
              entry.key,
              entry.value,
              isPlanned && _isEditing,
            );
          }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _deletePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            label: Text(
              isPlanned ? "删除训练计划" : "删除训练记录",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 统计项组件
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    int index,
    WorkoutSessionLog exercise,
    bool isEditable,
  ) {
    final volume = _calculateExerciseVolume(exercise);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12), // 修改右侧 padding
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 动作名称 - 可编辑
                      if (isEditable)
                        _ExerciseNameInput(
                          exercise: exercise,
                          onChanged: () => setState(() {}),
                        )
                      else
                        Text(
                          exercise.exerciseName ?? "未命名动作",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        "单动作总容量: ${volume.toInt()}kg",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEditable)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.redAccent, // 修改：改为红色
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _session!.exercises.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        "组数",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "重量(kg)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
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
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        "容量(kg)",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isEditable) const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 8),

                ...exercise.sets.asMap().entries.map((setEntry) {
                  if (isEditable) {
                    return _SetRowInput(
                      key: ValueKey('${index}_${setEntry.key}'),
                      index: setEntry.key,
                      set: setEntry.value,
                      onRemove: () {
                        setState(() {
                          exercise.sets.removeAt(setEntry.key);
                        });
                      },
                      onChanged: () {
                        setState(() {});
                      },
                    );
                  } else {
                    return _buildSetRowDisplay(setEntry.key, setEntry.value);
                  }
                }),

                if (isEditable) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          double w = 20;
                          int r = 12;
                          if (exercise.sets.isNotEmpty) {
                            w = exercise.sets.last.weight;
                            r = exercise.sets.last.reps;
                          }
                          exercise.sets.add(
                            WorkoutSet()
                              ..weight = w
                              ..reps = r
                              ..isCompleted = false,
                          );
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F75FF),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("添加组"),
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

  Widget _buildSetRowDisplay(int index, WorkoutSet set) {
    final volume = (set.weight * set.reps).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              set.weight.toStringAsFixed(1).replaceAll(".0", ""),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              set.reps.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              volume.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F75FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updatePlan() async {
    final isar = await IsarService().db;
    await isar.writeTxn(() async {
      await isar.workoutSessions.put(_session!);
    });

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存成功')));
      // 返回时通知刷新
      Navigator.pop(context, true);
    }
  }

  void _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认删除"),
        content: Text(
          _session!.status == 'planned' ? "确定要删除这个训练计划吗？" : "确定要删除这条训练记录吗？",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("删除"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final isar = await IsarService().db;
      await isar.writeTxn(() async {
        await isar.workoutSessions.delete(widget.sessionId);
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}

// 动作名称输入组件
class _ExerciseNameInput extends StatefulWidget {
  final WorkoutSessionLog exercise;
  final VoidCallback onChanged;

  const _ExerciseNameInput({required this.exercise, required this.onChanged});

  @override
  State<_ExerciseNameInput> createState() => _ExerciseNameInputState();
}

class _ExerciseNameInputState extends State<_ExerciseNameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.exercise.exerciseName ?? "",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "输入动作名称",
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: (value) {
          widget.exercise.exerciseName = value;
          widget.onChanged();
        },
      ),
    );
  }
}

// 组输入行组件
class _SetRowInput extends StatefulWidget {
  final int index;
  final WorkoutSet set;
  final VoidCallback onRemove;
  final VoidCallback? onChanged;

  const _SetRowInput({
    super.key,
    required this.index,
    required this.set,
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
    _weightCtrl = TextEditingController(
      text: widget.set.weight.toStringAsFixed(1).replaceAll(".0", ""),
    );
    _repsCtrl = TextEditingController(text: widget.set.reps.toString());
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              "${widget.index + 1}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  widget.set.weight = double.tryParse(val) ?? 0;
                  widget.onChanged?.call();
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
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
          SizedBox(
            width: 60,
            child: Text(
              "${(widget.set.weight * widget.set.reps).toInt()}",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F75FF),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
