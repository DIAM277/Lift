import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/workout.dart';
import '../../data/isar_service.dart';
import '../widgets/exercise_card.dart';

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
  late TextEditingController _noteController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadSession();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
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
        controller: _scrollController,
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

          // 使用通用动作卡片组件
          ..._session!.exercises.asMap().entries.map((entry) {
            return ExerciseCard<WorkoutSessionLog>(
              key: ValueKey('session_${entry.key}'),
              index: entry.key,
              exercise: entry.value,
              isEditable: isPlanned && _isEditing,
              showBodyweightToggle: true,
              showVolume: false,
              onRemove: () {
                setState(() {
                  _session!.exercises.removeAt(entry.key);
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
            if (isPlanned && _isEditing)
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

            if (isPlanned && _isEditing) const SizedBox(width: 12),

            // 删除训练计划按钮
            Expanded(
              child: SizedBox(
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
                    isPlanned ? "删除计划" : "删除记录",
                    style: const TextStyle(
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

  void _addExercise() {
    setState(() {
      _session!.exercises.add(
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
    }
  }

  void _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认删除"),
        content: Text(
          _session!.status == 'planned' ? "确定要删除这个训练计划吗?" : "确定要删除这条训练记录吗？",
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
