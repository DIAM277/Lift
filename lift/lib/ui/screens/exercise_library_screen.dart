import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise.dart';
import '../../providers/exercise_provider.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 首次启动触发预设数据写入
    ref.read(seedExercisesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          '动作库',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F75FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F75FF),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "预设动作"),
            Tab(text: "自定义动作"),
          ],
        ),
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          // 过滤预设动作和自定义动作
          final presets = exercises.where((e) => !e.isCustom).toList();
          final customs = exercises.where((e) => e.isCustom).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildExerciseList(presets), // 预设动作页面
              _buildExerciseList(customs, isCustomTab: true), // 自定义动作页面
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 添加动作页面/框
        },
        label: const Text('添加动作'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4F75FF),
      ),
    );
  }

  // 构建动作列表：按照部位分组
  Widget _buildExerciseList(List<Exercise> list, {bool isCustomTab = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              isCustomTab ? "没有自定义动作" : "暂无动作",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    // 关键逻辑：把扁平的list按照targetpart分组
    // eg. Map:{"胸部":["卧推", "俯卧撑"], "背部":["引体向上"]}
    final Map<String, List<Exercise>> grouped = {};
    for (var e in list) {
      if (!grouped.containsKey(e.targetPart)) {
        grouped[e.targetPart] = [];
      }
      grouped[e.targetPart]!.add(e);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final part = grouped.keys.elementAt(index);
        final partExercises = grouped[part]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片标题：部位名称
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$part训练",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 12),

              // 动作气泡流
              Wrap(
                spacing: 8, // 水平间距
                runSpacing: 8, // 垂直间距
                children: partExercises.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF), // 浅蓝色背景
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.name,
                      style: const TextStyle(
                        color: Color(0xFF4F75FF),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              // 底部操作栏
              Divider(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.edit_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    "编辑",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.add, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    "添加动作",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
