import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../../widgets/rest_timer_overlay.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final int sessionId;

  const WorkoutSessionScreen({super.key, required this.sessionId});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  WorkoutSession? _session;
  bool _isLoading = true;
  bool _showRestTimer = false;
  DateTime? _startTime;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final isar = await IsarService().db;
    final session = await isar.workoutSessions.get(widget.sessionId);

    if (session != null) {
      setState(() {
        _session = session;
        _startTime = DateTime.now();
        _isLoading = false;
      });
      _startElapsedTimer();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
        });
      }
    });
  }

  // 检查是否所有组都已完成
  bool _isExerciseCompleted(WorkoutSessionLog exercise) {
    return exercise.sets.every((set) => set.isCompleted);
  }

  // 检查是否所有动作都已完成
  bool _isAllCompleted() {
    return _session!.exercises.every((ex) => _isExerciseCompleted(ex));
  }

  // 计算总容量
  double _calculateTotalVolume() {
    double total = 0;
    for (var exercise in _session!.exercises) {
      for (var set in exercise.sets) {
        if (set.isCompleted) {
          total += set.weight * set.reps;
        }
      }
    }
    return total;
  }

  // 计算已完成的组数
  String _getCompletedSetsInfo() {
    int completed = 0;
    int total = 0;
    for (var exercise in _session!.exercises) {
      for (var set in exercise.sets) {
        total++;
        if (set.isCompleted) completed++;
      }
    }
    return '$completed / $total';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmation(),
            ),
            title: const Text(
              "训练进行中",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (_isAllCompleted())
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _completeWorkout,
                ),
            ],
          ),
          body: Column(
            children: [
              // 顶部统计卡片
              Container(
                margin: const EdgeInsets.all(16),
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
                  children: [
                    Text(
                      _session!.note ?? "今日训练",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          Icons.fitness_center,
                          "${_calculateTotalVolume().toInt()}",
                          "总容量(kg)",
                        ),
                        _buildStatColumn(
                          Icons.checklist,
                          _getCompletedSetsInfo(),
                          "完成组数",
                        ),
                        _buildStatColumn(
                          Icons.timer_outlined,
                          _getElapsedTime(),
                          "训练时长",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 动作列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _session!.exercises.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseCard(
                      _session!.exercises[index],
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isAllCompleted()
                ? SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _completeWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "完成训练",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: GestureDetector(
                      onLongPress: () => _showForceEndDialog(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop_circle_outlined,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "长按结束锻炼",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // 休息计时器覆盖层
        if (_showRestTimer)
          RestTimerOverlay(
            durationInSeconds: 120, // 2分钟
            onComplete: () {
              setState(() {
                _showRestTimer = false;
              });
              _showRestCompleteSnackbar();
            },
          ),
      ],
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF4F75FF)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _getElapsedTime() {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return "${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildExerciseCard(WorkoutSessionLog exercise, int exerciseIndex) {
    final isCompleted = _isExerciseCompleted(exercise);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName ?? "未命名动作",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "动作 ${exerciseIndex + 1}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
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
                        "重量(kg)",
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
                    const SizedBox(width: 80),
                  ],
                ),
                const SizedBox(height: 6),

                // 组列表
                ...exercise.sets.asMap().entries.map((entry) {
                  return _buildSetRow(
                    exercise,
                    entry.key,
                    entry.value,
                    exerciseIndex,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    WorkoutSessionLog exercise,
    int setIndex,
    WorkoutSet set,
    int exerciseIndex,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              "${setIndex + 1}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: set.isCompleted ? Colors.green : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: set.isCompleted ? Colors.white : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: set.isCompleted
                    ? Text(
                        set.weight.toStringAsFixed(1).replaceAll(".0", ""),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      )
                    : TextFormField(
                        initialValue: set.weight
                            .toStringAsFixed(1)
                            .replaceAll(".0", ""),
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
                          set.weight = double.tryParse(val) ?? 0;
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: set.isCompleted ? Colors.white : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: set.isCompleted
                    ? Text(
                        set.reps.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      )
                    : TextFormField(
                        initialValue: set.reps.toString(),
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
                          set.reps = int.tryParse(val) ?? 0;
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: set.isCompleted
                ? const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _completeSet(exercise, setIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F75FF),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "完成",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _completeSet(WorkoutSessionLog exercise, int setIndex) {
    setState(() {
      exercise.sets[setIndex].isCompleted = true;
    });

    // 检查是否还有未完成的组
    final hasMoreSets = exercise.sets.any((set) => !set.isCompleted);

    if (hasMoreSets) {
      // 显示休息计时器
      setState(() {
        _showRestTimer = true;
      });
    } else {
      // 该动作所有组都完成了
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.exerciseName} 已完成！'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showRestCompleteSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('休息结束，继续加油！'),
        backgroundColor: Color(0xFF4F75FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "确认退出",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("训练还未完成，确定要退出吗？进度将不会保存。"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("继续训练"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("退出"),
          ),
        ],
      ),
    );
  }

  void _showForceEndDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "提前结束训练",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("确定要结束训练吗？已完成的组将被保存为训练记录。"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("继续训练"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _completeWorkout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text("结束训练"),
          ),
        ],
      ),
    );
  }

  void _completeWorkout() async {
    final endTime = DateTime.now();
    final duration = (_elapsedSeconds / 60).ceil();

    setState(() {
      _session!.endTime = endTime;
      _session!.duration = duration;
      _session!.totalVolume = _calculateTotalVolume();
      _session!.status = 'completed';
    });

    final isar = await IsarService().db;
    await isar.writeTxn(() async {
      await isar.workoutSessions.put(_session!);
    });

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "训练完成！",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.fitness_center,
              "总容量",
              "${_session!.totalVolume.toInt()}kg",
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.timer_outlined,
              "训练时长",
              "${_session!.duration}分钟",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F75FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "太棒了",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
