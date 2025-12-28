import 'package:flutter/material.dart';
import '../../data/isar_service.dart';
import '../../data/models/routine.dart';
import '../widgets/exercise_card.dart';

class RoutineDetailScreen extends StatefulWidget {
  final int routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  WorkoutRoutine? _routine;
  bool _isEditing = false;
  bool _isLoading = true;
  late TextEditingController _nameController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadRoutine();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutine() async {
    final isar = await IsarService().db;
    final routine = await isar.workoutRoutines.get(widget.routineId);

    if (routine != null) {
      setState(() {
        _routine = _deepCopyRoutine(routine);
        _nameController.text = _routine!.name;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  WorkoutRoutine _deepCopyRoutine(WorkoutRoutine original) {
    final copy = WorkoutRoutine()
      ..id = original.id
      ..name = original.name
      ..exercises = original.exercises.map((exercise) {
        return RoutineExercise()
          ..exerciseName = exercise.exerciseName
          //..targetPart = exercise.targetPart
          ..isBodyweight = exercise.isBodyweight
          ..sets = exercise.sets.map((set) {
            return RoutineSet()
              ..weight = set.weight
              ..reps = set.reps;
          }).toList();
      }).toList();

    return copy;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _routine == null) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: const Text(
          "动作组合详情",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _updateRoutine();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Text(
              _isEditing ? "保存" : "编辑",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // 组合名称卡片
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
                        color: const Color(0xFF4F75FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFF4F75FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "动作组合信息",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 组合名称 - 可编辑
                if (_isEditing)
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
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "输入组合名称",
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _routine!.name = value;
                      },
                    ),
                  )
                else
                  Text(
                    _routine!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.list_alt, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      "${_routine!.exercises.length} 个动作",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 使用通用动作卡片组件
          ..._routine!.exercises.asMap().entries.map((entry) {
            return ExerciseCard<RoutineExercise>(
              key: ValueKey('routine_detail_${entry.key}'),
              index: entry.key,
              exercise: entry.value,
              isEditable: _isEditing,
              showBodyweightToggle: true,
              showVolume: false,
              onRemove: () {
                setState(() {
                  _routine!.exercises.removeAt(entry.key);
                });
              },
              onChanged: () {
                setState(() {});
              },
            );
          }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 添加动作按钮（仅在编辑状态显示）
            if (_isEditing)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F75FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "添加动作",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            if (_isEditing) const SizedBox(width: 12),

            // 删除组合按钮
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _deleteRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text(
                    "删除组合",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _routine!.exercises.add(
        RoutineExercise()
          ..exerciseName = "新动作"
          ..isBodyweight = false
          ..sets = [
            RoutineSet()
              ..weight = 20
              ..reps = 12,
          ],
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateRoutine() async {
    if (_routine!.name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入组合名称')));
      return;
    }
    if (_routine!.exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少添加一个动作')));
      return;
    }

    final isar = await IsarService().db;
    await isar.writeTxn(() async {
      await isar.workoutRoutines.put(_routine!);
    });

    if (mounted) {
      setState(() {
        _isEditing = false;
        _nameController.text = _routine!.name;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存成功')));
    }
  }

  void _deleteRoutine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "确认删除",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("确定要删除这个动作组合吗？删除后无法恢复。"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        await isar.workoutRoutines.delete(widget.routineId);
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('组合已删除')));
      }
    }
  }
}
