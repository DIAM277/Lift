import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/workout.dart';
import '../../../data/isar_service.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/detail_header_card.dart'; // ✅ 添加导入

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

    final isPlanned = _session!.status == 'planned';
    final isCompleted = _session!.status == 'completed';

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
          isPlanned ? "训练计划详情" : "训练记录详情",
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
          // 头部信息卡片 - 使用通用组件
          _buildHeaderCard(),
          const SizedBox(height: 20),

          // 动作列表标题
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
                    "${_session!.exercises.length}",
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

          // 使用通用动作卡片组件
          if (_session!.exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    "还没有添加动作",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ..._session!.exercises.asMap().entries.map((entry) {
              return ExerciseCard<WorkoutSessionLog>(
                key: ValueKey('session_${entry.key}'),
                index: entry.key,
                exercise: entry.value,
                isEditable: isPlanned && _isEditing,
                showBodyweightToggle: true,
                showVolume: isCompleted,
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

  // ✅ 替换原来的 _buildHeaderCard 方法
  Widget _buildHeaderCard() {
    final isCompleted = _session!.status == 'completed';
    final isPlanned = _session!.status == 'planned';

    final dateStr = DateFormat(
      'yyyy年MM月dd日 HH:mm',
      'zh_CN',
    ).format(_session!.startTime);

    // 构建统计项列表
    final List<DetailStatItem> stats = [
      DetailStatItem(
        icon: Icons.fitness_center,
        value: "${_session!.exercises.length}",
        label: "动作数",
        color: const Color(0xFF4F75FF),
      ),
    ];

    // 如果是已完成状态，添加容量和时长统计
    if (isCompleted) {
      stats.addAll([
        DetailStatItem(
          icon: Icons.monitor_weight,
          value: "${_session!.totalVolume.toInt()}kg",
          label: "总容量",
          color: Colors.orange,
        ),
        DetailStatItem(
          icon: Icons.timer_outlined,
          value: "${_session!.duration}分钟",
          label: "时长",
          color: Colors.green,
        ),
      ]);
    }

    return DetailHeaderCard(
      primaryColor: isCompleted
          ? Colors.green
          : isPlanned
          ? Colors.orange
          : const Color(0xFF4F75FF),
      icon: isCompleted
          ? Icons.check_circle
          : isPlanned
          ? Icons.schedule
          : Icons.fitness_center,
      typeLabel: isCompleted
          ? "已完成"
          : isPlanned
          ? "计划中"
          : "训练",
      typeInfo: dateStr,
      title: _session!.note ?? "无备注",
      isEditing: isPlanned && _isEditing,
      titleController: (isPlanned && _isEditing) ? _noteController : null,
      onTitleChanged: (value) {
        _session!.note = value;
      },
      stats: stats,
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
    if (_session!.note == null || _session!.note!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入计划名称')));
      return;
    }

    if (_session!.exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少添加一个动作')));
      return;
    }

    final isar = await IsarService().db;
    await isar.writeTxn(() async {
      await isar.workoutSessions.put(_session!);
    });

    if (mounted) {
      setState(() {
        _isEditing = false;
        _noteController.text = _session!.note ?? "";
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
        title: const Text(
          "确认删除",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _session!.status == 'planned'
              ? "确定要删除这个训练计划吗？删除后无法恢复。"
              : "确定要删除这条训练记录吗？删除后无法恢复。",
        ),
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
        await isar.workoutSessions.delete(widget.sessionId);
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_session!.status == 'planned' ? '计划已删除' : '记录已删除'),
          ),
        );
      }
    }
  }
}
