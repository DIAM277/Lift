import 'package:flutter/material.dart';
import 'data/isar_service.dart';
import 'ui/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库服务
  // 注意：这里只是为了触发数据库生成，之后我们会用 Riverpod 来管理它
  final isarService = IsarService();
  await isarService.db;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // 全局背景色
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
