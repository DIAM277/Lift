import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../data/isar_service.dart';
import '../../data/models/workout.dart';
import '../../data/models/routine.dart';
import '../widgets/exercise_card.dart';

class AddPlanScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddPlanScreen({super.key, required this.selectedDate});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<WorkoutSessionLog> _exercises = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "添加训练计划",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text(
              "保存",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // 计划名称输入卡片
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
                        color: Colors.orangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "训练计划信息",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      hintText: "输入计划名称",
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 使用通用动作卡片组件
          ..._exercises.asMap().entries.map((entry) {
            return ExerciseCard<WorkoutSessionLog>(
              key: ValueKey('plan_${entry.key}'),
              index: entry.key,
              exercise: entry.value,
              isEditable: true,
              showBodyweightToggle: true,
              showVolume: false,
              onRemove: () {
                setState(() {
                  _exercises.removeAt(entry.key);
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
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showImportRoutineDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F75FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF4F75FF),
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: const Text(
                    "导入组合",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      _exercises.add(
        WorkoutSessionLog()
          ..exerciseName = "新动作"
          ..targetPart = ""
          ..sets = [
            WorkoutSet()
              ..weight = 20
              ..reps = 12
              ..isCompleted = false,
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

  void _showImportRoutineDialog() async {
    final isar = await IsarService().db;
    final routines = await isar.workoutRoutines.where().findAll();

    if (!mounted) return;

    if (routines.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('还没有创建任何动作组合')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "选择动作组合",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: routines.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F75FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF4F75FF),
                    size: 24,
                  ),
                ),
                title: Text(
                  routine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${routine.exercises.length} 个动作",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  _importRoutine(routine);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
        ],
      ),
    );
  }

  void _importRoutine(WorkoutRoutine routine) {
    setState(() {
      for (var routineEx in routine.exercises) {
        _exercises.add(
          WorkoutSessionLog()
            ..exerciseName = routineEx.exerciseName
            ..targetPart = ""
            ..sets = routineEx.sets.map((routineSet) {
              return WorkoutSet()
                ..weight = routineSet.weight
                ..reps = routineSet.reps
                ..isCompleted = false;
            }).toList(),
        );
      }
    });

    if (_nameController.text.isEmpty) {
      _nameController.text = routine.name;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已导入 ${routine.exercises.length} 个动作')),
    );
  }

  void _savePlan() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入计划名称')));
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少添加一个动作')));
      return;
    }

    final isar = await IsarService().db;
    final session = WorkoutSession()
      ..startTime = widget.selectedDate
      ..status = 'planned'
      ..note = _nameController.text
      ..exercises = _exercises;

    await isar.writeTxn(() async {
      await isar.workoutSessions.put(session);
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
