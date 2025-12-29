import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:isar/isar.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../../../services/statistics_service.dart';
import '../../../services/muscle_group_service.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _recentSessions = [];
  bool _isLoading = true;

  // 趋势数据周期选择
  String _trendPeriod = '3个月'; // 3个月/6个月/近30天

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = await IsarService().db;

    // 获取所有已完成的训练
    final sessions = await isar.workoutSessions
        .filter()
        .statusEqualTo('completed')
        .sortByStartTimeDesc()
        .findAll();

    // 获取最近3个月的数据
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentSessions = sessions
        .where((s) => s.startTime.isAfter(threeMonthsAgo))
        .toList();

    setState(() {
      _allSessions = sessions;
      _recentSessions = recentSessions;
      _isLoading = false;
    });
  }

  int _getPeriodMonths() {
    switch (_trendPeriod) {
      case '近30天':
        return 1;
      case '6个月':
        return 6;
      default:
        return 3;
    }
  }

  List<WorkoutSession> _getFilteredSessions() {
    final months = _getPeriodMonths();
    final cutoffDate = DateTime.now().subtract(Duration(days: months * 30));
    return _allSessions.where((s) => s.startTime.isAfter(cutoffDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
        appBar: AppBar(
          title: const Text(
            "训练统计",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary, // ✅ 使用主题主色
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ 使用主题背景色
      appBar: AppBar(
        title: const Text(
          "训练统计",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor, // ✅ 使用主题卡片色
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: colorScheme.primary, // ✅ 使用主题主色
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. 核心累计数据
            _buildOverviewSection(colorScheme),
            const SizedBox(height: 24),

            // 2. 趋势类数据
            _buildTrendSection(theme, colorScheme),
            const SizedBox(height: 24),

            // 3. 维度拆解数据
            _buildDimensionSection(theme, colorScheme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== 1. 核心累计数据 ====================
  Widget _buildOverviewSection(ColorScheme colorScheme) {
    final totalDays = StatisticsService.calculateTotalDays(_allSessions);
    final totalVolume = StatisticsService.calculateTotalVolume(_allSessions);
    final totalDuration = StatisticsService.calculateTotalDuration(
      _allSessions,
    );
    final uniqueExercises = StatisticsService.calculateUniqueExercises(
      _allSessions,
    );

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "累计成就",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  Icons.calendar_today,
                  totalDays.toString(),
                  "训练天数",
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  Icons.fitness_center,
                  "${(totalVolume / 1000).toStringAsFixed(1)}",
                  "总容量(吨)",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  Icons.access_time,
                  "${(totalDuration / 60).toStringAsFixed(1)}",
                  "训练时长(时)",
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  Icons.list_alt,
                  uniqueExercises.toString(),
                  "解锁动作",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  // ==================== 2. 趋势类数据 ====================
  Widget _buildTrendSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "趋势分析",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
              ),
            ),
            // 周期选择器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardColor, // ✅ 使用主题卡片色
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor), // ✅ 使用主题分割线色
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _trendPeriod,
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                  ),
                  dropdownColor: theme.cardColor, // ✅ 下拉菜单背景色
                  items: ['近30天', '3个月', '6个月'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _trendPeriod = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 月训练次数趋势
        _buildWorkoutTrendChart(theme, colorScheme),
        const SizedBox(height: 16),

        // 月度训练容量趋势
        _buildVolumeTrendChart(theme),
        const SizedBox(height: 16),

        // 周训练频率分布
        _buildWeeklyFrequencyChart(theme),
      ],
    );
  }

  Widget _buildWorkoutTrendChart(ThemeData theme, ColorScheme colorScheme) {
    final filteredSessions = _getFilteredSessions();
    final trendData = StatisticsService.getMonthlyWorkoutTrend(
      filteredSessions,
      _getPeriodMonths(),
    );

    return _buildChartCard(
      title: "月训练次数",
      icon: Icons.show_chart,
      color: colorScheme.primary, // ✅ 使用主题主色
      theme: theme,
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.dividerColor, // ✅ 使用主题分割线色
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < trendData.length) {
                        final key = trendData.keys.elementAt(index);
                        final month = key.split('-')[1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${month}月',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.color, // ✅ 使用主题文字色
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: trendData.entries.map((e) {
                    final index = trendData.keys.toList().indexOf(e.key);
                    return FlSpot(index.toDouble(), e.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: colorScheme.primary, // ✅ 使用主题主色
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: theme.cardColor, // ✅ 使用主题卡片色
                        strokeWidth: 2,
                        strokeColor: colorScheme.primary, // ✅ 使用主题主色
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.1), // ✅ 使用主题主色
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeTrendChart(ThemeData theme) {
    final filteredSessions = _getFilteredSessions();
    final volumeData = StatisticsService.getMonthlyVolumeTrend(
      filteredSessions,
      _getPeriodMonths(),
    );

    return _buildChartCard(
      title: "月度训练容量",
      icon: Icons.bar_chart,
      color: Colors.green,
      theme: theme,
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: volumeData.values.isEmpty
                  ? 1
                  : volumeData.values.reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 1000).toStringAsFixed(0)}t',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < volumeData.length) {
                        final key = volumeData.keys.elementAt(index);
                        final month = key.split('-')[1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${month}月',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.color, // ✅ 使用主题文字色
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: volumeData.values.isEmpty
                    ? 1
                    : volumeData.values.reduce((a, b) => a > b ? a : b) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.dividerColor, // ✅ 使用主题分割线色
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: volumeData.entries.map((e) {
                final index = volumeData.keys.toList().indexOf(e.key);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      color: Colors.green,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyFrequencyChart(ThemeData theme) {
    final weekData = StatisticsService.getWeeklyFrequency(_recentSessions);
    final total = weekData.values.fold<int>(0, (sum, count) => sum + count);

    return _buildChartCard(
      title: "周训练频率分布",
      subtitle: "最近一周",
      icon: Icons.pie_chart,
      color: Colors.orange,
      theme: theme,
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: weekData.entries.map((e) {
                      final percentage = total > 0
                          ? (e.value / total * 100)
                          : 0;
                      final colors = [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.red,
                        Colors.teal,
                        Colors.pink,
                      ];
                      final index = weekData.keys.toList().indexOf(e.key);

                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: e.value > 0
                            ? '${percentage.toStringAsFixed(0)}%'
                            : '',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        color: colors[index % colors.length],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weekData.entries.map((e) {
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                    Colors.pink,
                  ];
                  final index = weekData.keys.toList().indexOf(e.key);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${e.key}: ${e.value}次',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.color, // ✅ 使用主题文字色
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ==================== 3. 维度拆解数据 ====================
  Widget _buildDimensionSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "训练结构",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
          ),
        ),
        const SizedBox(height: 16),

        // 各部位训练占比
        _buildMuscleGroupChart(theme, colorScheme),
        const SizedBox(height: 16),

        // 动作使用频率 Top 5
        _buildTopExercises(theme),
      ],
    );
  }

  Widget _buildMuscleGroupChart(ThemeData theme, ColorScheme colorScheme) {
    final distribution = StatisticsService.getMuscleGroupDistribution(
      _recentSessions,
    );
    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);

    if (total == 0) {
      return _buildChartCard(
        title: "各部位训练占比",
        subtitle: "最近三个月",
        icon: Icons.fitness_center,
        color: colorScheme.primary, // ✅ 使用主题主色
        theme: theme,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              "暂无数据",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
              ), // ✅ 使用主题文字色
            ),
          ),
        ),
      );
    }

    return _buildChartCard(
      title: "各部位训练占比",
      subtitle: "最近三个月",
      icon: Icons.fitness_center,
      color: colorScheme.primary, // ✅ 使用主题主色
      theme: theme,
      child: SizedBox(
        height: 240,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    sections: distribution.entries.map((e) {
                      final percentage = (e.value / total * 100);
                      final muscleGroup = MuscleGroupService.getMuscleGroup(
                        e.key,
                      );

                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: percentage >= 5
                            ? '${percentage.toStringAsFixed(0)}%'
                            : '',
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        color: muscleGroup.color,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: distribution.entries.map((e) {
                    final muscleGroup = MuscleGroupService.getMuscleGroup(
                      e.key,
                    );
                    final percentage = (e.value / total * 100).toStringAsFixed(
                      1,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: muscleGroup.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  muscleGroup.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: theme
                                        .textTheme
                                        .bodyLarge
                                        ?.color, // ✅ 使用主题文字色
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$percentage% (${e.value}次)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme
                                        .textTheme
                                        .bodyMedium
                                        ?.color, // ✅ 使用主题文字色
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExercises(ThemeData theme) {
    final topExercises = StatisticsService.getTopExercises(_recentSessions, 5);

    if (topExercises.isEmpty) {
      return _buildChartCard(
        title: "动作使用频率 Top 5",
        subtitle: "最近三个月",
        icon: Icons.format_list_numbered,
        color: Colors.purple,
        theme: theme,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              "暂无数据",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
              ), // ✅ 使用主题文字色
            ),
          ),
        ),
      );
    }

    final maxCount = topExercises.first.value;

    return _buildChartCard(
      title: "动作使用频率 Top 5",
      subtitle: "最近三个月",
      icon: Icons.format_list_numbered,
      color: Colors.purple,
      theme: theme,
      child: Column(
        children: topExercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final percentage = (exercise.value / maxCount);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                        ),
                      ),
                    ),
                    Text(
                      '${exercise.value}次',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.dividerColor, // ✅ 使用主题分割线色
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.purple,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required ThemeData theme, // ✅ 添加 theme 参数
    required Widget child,
  }) {
    return Container(
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color, // ✅ 使用主题文字色
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color, // ✅ 使用主题文字色
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
