import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../data/models/workout.dart';
import '../data/models/routine.dart';
import 'package:intl/intl.dart';

class ExportService {
  // ✅ 修改为返回文件路径，不使用 share_plus
  static Future<String> exportWorkoutsToCSV(
    List<WorkoutSession> sessions,
  ) async {
    try {
      List<List<dynamic>> rows = [
        [
          '日期',
          '时间',
          '计划名称',
          '状态',
          '动作',
          '组数',
          '重量(kg)',
          '次数',
          '总容量(kg)',
          '训练时长(分钟)',
        ],
      ];

      for (var session in sessions) {
        final dateStr = DateFormat('yyyy-MM-dd').format(session.startTime);
        final timeStr = DateFormat('HH:mm').format(session.startTime);
        final status = session.status == 'completed' ? '已完成' : '计划中';

        if (session.exercises.isEmpty) {
          rows.add([
            dateStr,
            timeStr,
            session.note ?? '无备注',
            status,
            '',
            '',
            '',
            '',
            session.totalVolume.toStringAsFixed(1),
            session.duration.toString(),
          ]);
        } else {
          for (var exercise in session.exercises) {
            for (var i = 0; i < exercise.sets.length; i++) {
              final set = exercise.sets[i];
              rows.add([
                dateStr,
                timeStr,
                session.note ?? '无备注',
                status,
                exercise.exerciseName ?? '未命名',
                '第${i + 1}组',
                set.weight.toStringAsFixed(1),
                set.reps.toString(),
                i == 0 ? session.totalVolume.toStringAsFixed(1) : '',
                i == 0 ? session.duration.toString() : '',
              ]);
            }
          }
        }
      }

      String csv = const ListToCsvConverter().convert(rows);

      // ✅ 保存到 Documents 目录
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/lift_workouts_$timestamp.csv';
      final file = File(filePath);

      await file.writeAsBytes([0xEF, 0xBB, 0xBF] + utf8.encode(csv));

      return filePath; // ✅ 返回文件路径
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> exportWorkoutsToJSON(
    List<WorkoutSession> sessions,
  ) async {
    try {
      final data = {
        'export_date': DateTime.now().toIso8601String(),
        'total_workouts': sessions.length,
        'workouts': sessions.map((session) {
          return {
            'id': session.id,
            'date': session.startTime.toIso8601String(),
            'note': session.note,
            'status': session.status,
            'duration': session.duration,
            'total_volume': session.totalVolume,
            'exercises': session.exercises.map((exercise) {
              return {
                'name': exercise.exerciseName,
                'target_part': exercise.targetPart,
                'sets': exercise.sets.map((set) {
                  return {
                    'weight': set.weight,
                    'reps': set.reps,
                    'is_completed': set.isCompleted,
                  };
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
      };

      String jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/lift_workouts_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonStr);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> exportRoutinesToJSON(
    List<WorkoutRoutine> routines,
  ) async {
    try {
      final data = {
        'export_date': DateTime.now().toIso8601String(),
        'total_routines': routines.length,
        'routines': routines.map((routine) {
          return {
            'id': routine.id,
            'name': routine.name,
            'description': routine.description,
            'exercises': routine.exercises.map((exercise) {
              return {
                'name': exercise.exerciseName,
                'sets': exercise.sets.map((set) {
                  return {'weight': set.weight, 'reps': set.reps};
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
      };

      String jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/lift_routines_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonStr);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> exportAllData(
    List<WorkoutSession> sessions,
    List<WorkoutRoutine> routines,
  ) async {
    try {
      final data = {
        'app': 'Lift',
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'statistics': {
          'total_workouts': sessions
              .where((s) => s.status == 'completed')
              .length,
          'total_plans': sessions.where((s) => s.status == 'planned').length,
          'total_routines': routines.length,
          'total_volume': sessions.fold<double>(
            0,
            (sum, s) => sum + s.totalVolume,
          ),
        },
        'workouts': sessions.map((session) {
          return {
            'id': session.id,
            'date': session.startTime.toIso8601String(),
            'end_date': session.endTime?.toIso8601String(),
            'note': session.note,
            'status': session.status,
            'duration': session.duration,
            'total_volume': session.totalVolume,
            'exercises': session.exercises.map((exercise) {
              return {
                'name': exercise.exerciseName,
                'target_part': exercise.targetPart,
                'sets': exercise.sets.map((set) {
                  return {
                    'weight': set.weight,
                    'reps': set.reps,
                    'is_completed': set.isCompleted,
                  };
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
        'routines': routines.map((routine) {
          return {
            'id': routine.id,
            'name': routine.name,
            'description': routine.description,
            'exercises': routine.exercises.map((exercise) {
              return {
                'name': exercise.exerciseName,
                'sets': exercise.sets.map((set) {
                  return {'weight': set.weight, 'reps': set.reps};
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
      };

      String jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/lift_backup_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonStr);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }
}
