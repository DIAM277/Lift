import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../data/isar_service.dart';
import '../../data/models/workout.dart';
import '../../data/models/routine.dart';

class AddPlanScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddPlanScreen({super.key, required this.selectedDate});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<WorkoutSessionLog> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 计划名称输入
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "给训练计划起个名字",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 动作导入按钮组
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddExerciseDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F75FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("添加动作"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showImportRoutineDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F75FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.file_download),
                        label: const Text("导入组合"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 动作卡片列表
                ..._exercises.asMap().entries.map((entry) {
                  return _buildExerciseCard(entry.key, entry.value);
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, WorkoutSessionLog exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 卡片头部
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName ?? "未命名动作",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _exercises.removeAt(index)),
              ),
            ],
          ),
          const Divider(),

          // 表头
          Row(
            children: const [
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    "组",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "重量 (kg)",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "次数",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),

          // 组列表
          ...exercise.sets.asMap().entries.map((setEntry) {
            return _SetRowInput(
              index: setEntry.key,
              set: setEntry.value,
              onRemove: () =>
                  setState(() => exercise.sets.removeAt(setEntry.key)),
            );
          }),

          // 添加组按钮
          TextButton.icon(
            onPressed: () => setState(() {
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
            }),
            icon: const Icon(Icons.add, size: 16),
            label: const Text("添加组"),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    String tempName = "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("添加动作"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "输入动作名称"),
          onChanged: (v) => tempName = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (tempName.isNotEmpty) {
                setState(() {
                  _exercises.add(
                    WorkoutSessionLog()
                      ..exerciseName = tempName
                      ..sets = [
                        WorkoutSet()
                          ..weight = 20
                          ..reps = 12
                          ..isCompleted = false,
                      ],
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
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
        title: const Text("选择动作组合"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return ListTile(
                title: Text(routine.name),
                subtitle: Text("${routine.exercises.length} 个动作"),
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
      // 深拷贝 Routine 的数据
      for (var routineEx in routine.exercises) {
        _exercises.add(
          WorkoutSessionLog()
            ..exerciseName = routineEx.exerciseName
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
  }

  void _savePlan() async {
    if (_nameController.text.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入计划名称并添加至少一个动作')));
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
      Navigator.pop(context, true); // 返回 true 表示添加成功
    }
  }
}

// 组输入行组件
class _SetRowInput extends StatefulWidget {
  final int index;
  final WorkoutSet set;
  final VoidCallback onRemove;

  const _SetRowInput({
    required this.index,
    required this.set,
    required this.onRemove,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                "${widget.index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (val) =>
                    widget.set.weight = double.tryParse(val) ?? 0,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (val) => widget.set.reps = int.tryParse(val) ?? 0,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
