import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../../../data/models/routine.dart';
import '../../widgets/exercise_card.dart';

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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F75FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "今天";
    } else if (dateOnly == tomorrow) {
      return "明天";
    } else {
      return DateFormat('MM月dd日 EEEE', 'zh_CN').format(date);
    }
  }

  Color _getDateColor() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return dateOnly == today ? const Color(0xFF4F75FF) : Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
      appBar: AppBar(
        title: const Text(
          "添加训练计划",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: Text(
              "保存",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary, // ✅ 使用主题主色
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
          // 计划信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor, // ✅ 使用主题卡片色
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
                        color: _getDateColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: _getDateColor(),
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
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getDateColor().withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDateColor().withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: _getDateColor(), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "训练日期",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getDateColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardColor, // ✅ 使用主题卡片色
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "修改",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getDateColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_calendar,
                                size: 14,
                                color: _getDateColor(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "计划名称",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
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

          if (_exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Text(
                    "动作列表",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1), // ✅ 使用主题主色
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_exercises.length}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary, // ✅ 使用主题主色
                      ),
                    ),
                  ),
                ],
              ),
            ),

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

          if (_exercises.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.cardColor, // ✅ 使用主题卡片色
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
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "还没有添加动作",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "点击下方按钮添加动作或导入组合",
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
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
                    backgroundColor: colorScheme.primary, // ✅ 使用主题主色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "添加动作",
                    style: TextStyle(
                      fontSize: 15,
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
                    backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
                    foregroundColor: colorScheme.primary, // ✅ 使用主题主色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary, // ✅ 使用主题主色
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: const Text(
                    "导入组合",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  // ✅ 使用美观的底部弹窗选择器
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RoutineSelector(
        routines: routines,
        onSelected: (routine) {
          _importRoutine(routine);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _importRoutine(WorkoutRoutine routine) {
    setState(() {
      for (var routineEx in routine.exercises) {
        _exercises.add(
          WorkoutSessionLog()
            ..exerciseName = routineEx.exerciseName
            ..targetPart = routineEx.targetPart
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
      SnackBar(
        content: Text('已导入 ${routine.exercises.length} 个动作'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _savePlan() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("请至少添加一个动作")));
      return;
    }

    final isar = await IsarService().db;

    // ✅ 修复：保存计划时只使用日期部分，不包含时间
    final planDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final session = WorkoutSession()
      ..startTime =
          planDate // ✅ 只保存日期
      ..endTime = null
      ..note = _nameController.text.isEmpty ? null : _nameController.text
      ..status = 'planned'
      ..duration = 0
      ..totalVolume = 0
      ..exercises = _exercises;

    await isar.writeTxn(() async {
      await isar.workoutSessions.put(session);
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("计划已保存")));
    }
  }
}

class _RoutineSelector extends StatelessWidget {
  final List<WorkoutRoutine> routines;
  final ValueChanged<WorkoutRoutine> onSelected;

  const _RoutineSelector({required this.routines, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ 使用主题卡片色
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1), // ✅ 使用主题主色
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: colorScheme.primary, // ✅ 使用主题主色
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "选择动作组合",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // 组合列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: routines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final routine = routines[index];
                return InkWell(
                  onTap: () => onSelected(routine),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        // 左侧图标
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withOpacity(
                                  0.8,
                                ), // ✅ 使用主题主色
                                colorScheme.secondary, // ✅ 使用主题次色
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 组合信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme
                                      .textTheme
                                      .bodyLarge
                                      ?.color, // ✅ 使用主题文字色
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(
                                        0.1,
                                      ), // ✅ 使用主题主色
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${routine.exercises.length} 个动作",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.primary, // ✅ 使用主题主色
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (routine.description?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        routine.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 右侧箭头
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.cardColor, // ✅ 使用主题卡片色
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.primary, // ✅ 使用主题主色
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
