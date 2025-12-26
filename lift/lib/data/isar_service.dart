import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/exercise.dart';
import 'models/workout.dart';

class IsarService {
  // 创建单例,确保整个APP只有一个数据库连接以防冲突
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  // 数据库实例
  Future<Isar>? _db;

  // 智能的 getter
  // 外部调用 .db 时，如果发现没初始化，它会自动初始化；
  Future<Isar> get db {
    _db ??= _initDB(); // 如果 _db 是 null，就执行 _initDB()
    return _db!;
  }

  // 初始化逻辑
  Future<Isar> _initDB() async {
    // 如果已经打开过，直接获取实例
    if (Isar.instanceNames.isNotEmpty) {
      return Future.value(Isar.getInstance());
    }

    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [ExerciseSchema, WorkoutSessionSchema], //Schema
      directory: dir.path,
      inspector: true,
    );
  }

  // 预填充数据（只在第一次安装时运行）
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  // 添加动作
  Future<void> addExercise(String name, String targetPart) async {
    // 获取数据库实例
    final isar = await db;

    // 创建一个动作对象
    final exercise = Exercise()
      ..name = name
      ..targetPart = targetPart;

    // 写入操作，在事务中进行
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);
    });
  }

  // 获取所有动作
  Future<List<Exercise>> getAllExercises() async {
    final isar = await db;
    return await isar.exercises.where().findAll();
  }
}
