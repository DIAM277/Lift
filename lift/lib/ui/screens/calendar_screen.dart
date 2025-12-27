import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/models/workout.dart';
import '../../providers/calendar_provider.dart';
import 'add_plan_screen.dart';
import 'plan_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  bool _isSelectedDayTodayOrFuture() {
    if (_selectedDay == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    return !selected.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(monthlyWorkoutsProvider(_focusedDay));
    final selectedDayWorkoutsAsync = ref.watch(
      dailyWorkoutsProvider(_selectedDay ?? _focusedDay),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                  );
                });
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  '训练回顾 · ${DateFormat('yyyy年MM月', 'zh_CN').format(_focusedDay)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: workoutsAsync.when(
              data: (workouts) => _buildCalendar(workouts),
              loading: () => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Center(child: Text('加载失败: $err')),
            ),
          ),
          Expanded(
            child: selectedDayWorkoutsAsync.when(
              data: (workouts) => _buildDayWorkoutsList(workouts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('加载失败: $err')),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isSelectedDayTodayOrFuture()
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPlanScreen(selectedDate: _selectedDay!),
                      ),
                    );
                    if (result == true) {
                      ref.invalidate(dailyWorkoutsProvider(_selectedDay!));
                      ref.invalidate(monthlyWorkoutsProvider(_focusedDay));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F75FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "添加训练计划",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCalendar(List<WorkoutSession> workouts) {
    final Map<DateTime, List<WorkoutSession>> workoutsByDate = {};
    for (var workout in workouts) {
      final date = DateTime(
        workout.startTime.year,
        workout.startTime.month,
        workout.startTime.day,
      );
      workoutsByDate.putIfAbsent(date, () => []).add(workout);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        locale: 'zh_CN',
        headerVisible: false,
        daysOfWeekHeight: 40,
        rowHeight: 48,
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          cellMargin: const EdgeInsets.all(4),
          weekendTextStyle: const TextStyle(color: Colors.black87),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4F75FF),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF4F75FF),
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final dateKey = DateTime(date.year, date.month, date.day);
            final dayWorkouts = workoutsByDate[dateKey];

            if (dayWorkouts == null || dayWorkouts.isEmpty) return null;

            final hasCompleted = dayWorkouts.any(
              (w) => w.status == 'completed',
            );
            final hasPlanned = dayWorkouts.any((w) => w.status == 'planned');

            return Positioned(
              bottom: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCompleted)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F75FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasPlanned)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayWorkoutsList(List<WorkoutSession> workouts) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _isSelectedDayTodayOrFuture() ? "还没有训练计划\n点击下方按钮添加" : "这天还没有训练记录",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final dateStr = DateFormat('MM月dd日', 'zh_CN').format(_selectedDay!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            dateStr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...workouts.map((workout) => _buildWorkoutCard(workout)),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutSession session) {
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime).inMinutes
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: session.status == 'planned'
            ? Border.all(color: Colors.orangeAccent, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () async {
          // 关键修改：传递 session.id 而不是 session 对象
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailScreen(sessionId: session.id),
            ),
          );
          if (result == true) {
            // 刷新数据
            ref.invalidate(dailyWorkoutsProvider(_selectedDay!));
            ref.invalidate(monthlyWorkoutsProvider(_focusedDay));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: session.status == 'completed'
                      ? const Color(0xFF4F75FF)
                      : Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          session.note ?? "训练记录",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (session.status == 'planned')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "计划中",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.status == 'completed'
                          ? "总容量: ${session.totalVolume.toInt()}kg | 时长: ${duration}min"
                          : "${session.exercises.length} 个动作",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
