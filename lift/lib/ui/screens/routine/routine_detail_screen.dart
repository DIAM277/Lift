import 'package:flutter/material.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/routine.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/detail_header_card.dart'; // ✅ 添加导入

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
          // ..targetPart = exercise.targetPart
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
      body: Stack(
        // ✅ 使用 Stack 替代 floatingActionButton
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Text(
                      "动作列表",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F75FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_routine!.exercises.length}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F75FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_routine!.exercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "还没有添加动作",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
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
          // ✅ 底部按钮使用 Positioned
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
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
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
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
        ],
      ),
    );
  }

  // ✅ 替换原来的 _buildHeaderCard 方法
  Widget _buildHeaderCard() {
    return DetailHeaderCard(
      primaryColor: const Color(0xFF4F75FF),
      icon: Icons.folder_special,
      typeLabel: "动作组合",
      title: _routine!.name,
      isEditing: _isEditing,
      titleController: _isEditing ? _nameController : null,
      onTitleChanged: (value) {
        _routine!.name = value;
      },
      stats: [
        DetailStatItem(
          icon: Icons.fitness_center,
          value: "${_routine!.exercises.length}",
          label: "动作数",
          color: const Color(0xFF4F75FF),
        ),
        DetailStatItem(
          icon: Icons.list_alt,
          value: "${_getTotalSets()}",
          label: "总组数",
          color: Colors.orange,
        ),
      ],
    );
  }

  int _getTotalSets() {
    return _routine!.exercises.fold(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
  }

  void _addExercise() {
    setState(() {
      _routine!.exercises.add(
        RoutineExercise()
          ..exerciseName = "新动作"
          // ..targetPart = ""
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
