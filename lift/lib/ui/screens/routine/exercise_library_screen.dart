import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/routine.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<WorkoutRoutine> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() {
      _isLoading = true;
    });

    final isar = await IsarService().db;
    final routines = await isar.workoutRoutines.where().findAll();

    setState(() {
      _routines = routines;
      _isLoading = false;
    });
  }

  int _getTotalExercises() {
    return _routines.fold(0, (sum, routine) => sum + routine.exercises.length);
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
          "动作组合",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoutines,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary, // ✅ 使用主题主色
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 统计卡片
                  if (_routines.isNotEmpty) ...[
                    _buildStatsCard(theme, colorScheme),
                    const SizedBox(height: 20),

                    // 组合列表标题
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            "我的组合",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(
                                0.1,
                              ), // ✅ 使用主题主色
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${_routines.length}",
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
                  ],

                  // 组合列表
                  if (_routines.isEmpty)
                    _buildEmptyState()
                  else
                    ..._routines.map(
                      (routine) =>
                          _buildRoutineCard(routine, theme, colorScheme),
                    ),

                  // 底部留出空间
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRoutineScreen(),
                ),
              );
              if (result == true) {
                _loadRoutines();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // ✅ 使用主题主色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            label: const Text(
              "新建动作组合",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary], // ✅ 使用主题颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3), // ✅ 使用主题主色
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_special,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "动作库统计",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.collections_bookmark,
                "${_routines.length}",
                "组合数",
              ),
              _buildStatItem(
                Icons.fitness_center,
                "${_getTotalExercises()}",
                "动作数",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "还没有创建任何组合",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "点击下方按钮创建你的第一个动作组合吧",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(
    WorkoutRoutine routine,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final Map<String, int> partCounts = {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineDetailScreen(routineId: routine.id),
            ),
          );
          if (result == true) {
            _loadRoutines();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1), // ✅ 使用主题主色
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_special,
                      color: colorScheme.primary, // ✅ 使用主题主色
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${routine.exercises.length} 个动作",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),

              // 显示部位标签
              if (partCounts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: partCounts.entries.take(4).map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPartColor(entry.key).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPartIcon(entry.key),
                            size: 12,
                            color: _getPartColor(entry.key),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${entry.key} × ${entry.value}",
                            style: TextStyle(
                              fontSize: 11,
                              color: _getPartColor(entry.key),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPartColor(String part) {
    switch (part) {
      case "胸部":
        return Colors.red;
      case "背部":
        return Colors.blue;
      case "肩部":
        return Colors.orange;
      case "手臂":
        return Colors.green;
      case "腿部":
        return Colors.purple;
      case "核心":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getPartIcon(String part) {
    switch (part) {
      case "胸部":
        return Icons.favorite;
      case "背部":
        return Icons.airline_seat_recline_normal;
      case "肩部":
        return Icons.sports_martial_arts;
      case "手臂":
        return Icons.fitness_center;
      case "腿部":
        return Icons.directions_run;
      case "核心":
        return Icons.circle;
      default:
        return Icons.fiber_manual_record;
    }
  }
}
