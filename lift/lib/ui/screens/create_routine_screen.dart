import 'package:flutter/material.dart';
import '../../data/isar_service.dart';
import '../../data/models/routine.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<RoutineExercise> _exercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "新建动作组合",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveRoutine,
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
                // 1. 组合名称输入
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "给组合起个名字 (如: 胸肌锻炼)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. 动作卡片列表
                ..._exercises.asMap().entries.map((entry) {
                  return _buildExerciseCard(entry.key, entry.value);
                }),

                // 底部留白，防止被按钮遮挡
                const SizedBox(height: 80),
              ],
            ),
          ),

          // 3. 底部大按钮 (样式与首页一致)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showAddExerciseDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F75FF), // 主题蓝
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
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, RoutineExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 卡片头部：动作名 + 自重开关 + 删除
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 自重开关
              Column(
                children: [
                  const Text(
                    "自重",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Switch(
                    value: exercise.isBodyweight,
                    activeColor: const Color(0xFF4F75FF),
                    onChanged: (val) {
                      setState(() {
                        exercise.isBodyweight = val;
                        // 如果切换到自重，把所有组的重量设为0
                        if (val) {
                          for (var set in exercise.sets) {
                            set.weight = 0;
                          }
                        }
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _exercises.removeAt(index)),
              ),
            ],
          ),
          const Divider(),

          // 表头
          Row(
            children: [
              const SizedBox(
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
                    exercise.isBodyweight ? "类型" : "重量 (kg)",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "次数",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),

          // 组列表 (使用 _SetRowInput 独立组件来处理输入)
          ...exercise.sets.asMap().entries.map((setEntry) {
            return _SetRowInput(
              index: setEntry.key,
              set: setEntry.value,
              isBodyweight: exercise.isBodyweight,
              onRemove: () =>
                  setState(() => exercise.sets.removeAt(setEntry.key)),
            );
          }),

          // 添加组按钮
          TextButton.icon(
            onPressed: () => setState(() {
              // 自动继承上一组的数据
              double w = 20;
              int r = 12;
              if (exercise.sets.isNotEmpty) {
                w = exercise.sets.last.weight;
                r = exercise.sets.last.reps;
              }
              exercise.sets.add(
                RoutineSet()
                  ..weight = w
                  ..reps = r,
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
          decoration: const InputDecoration(hintText: "输入名称 (如: 卧推)"),
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
                  // ✅ 优化 1: 自动添加第一组
                  _exercises.add(
                    RoutineExercise()
                      ..exerciseName = tempName
                      ..isBodyweight = false
                      ..sets = [
                        RoutineSet()
                          ..weight = 20
                          ..reps = 12,
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

  void _saveRoutine() async {
    if (_nameController.text.isEmpty) return;
    final isar = await IsarService().db;
    final routine = WorkoutRoutine()
      ..name = _nameController.text
      ..exercises = _exercises;
    await isar.writeTxn(() async => await isar.workoutRoutines.put(routine));
    if (mounted) Navigator.pop(context);
  }
}

// --- 独立组件：处理每一行的输入 ---
class _SetRowInput extends StatefulWidget {
  final int index;
  final RoutineSet set;
  final bool isBodyweight;
  final VoidCallback onRemove;

  const _SetRowInput({
    required this.index,
    required this.set,
    required this.isBodyweight,
    required this.onRemove,
  });

  @override
  State<_SetRowInput> createState() => _SetRowInputState();
}

class _SetRowInputState extends State<_SetRowInput> {
  // 使用 Controller 确保输入不跳变
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
  void didUpdateWidget(covariant _SetRowInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果外部把自重打开了，我们需要更新显示
    if (widget.isBodyweight != oldWidget.isBodyweight) {
      if (widget.isBodyweight) _weightCtrl.text = "0";
    }
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

          // 重量输入框
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isBodyweight
                  ? const Center(
                      child: Text("自重", style: TextStyle(color: Colors.grey)),
                    ) // ✅ 优化 2: 自重显示文本
                  : TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (val) =>
                          widget.set.weight = double.tryParse(val) ?? 0,
                    ),
            ),
          ),

          // 次数输入框
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
