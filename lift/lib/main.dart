import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/isar_service.dart';
import 'ui/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/theme_provider.dart'; // ✅ 添加导入

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await isarService.db;
  await initializeDateFormatting('zh_CN', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // ✅ 改为 ConsumerWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 监听主题状态
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Lift - 健身记录',
      debugShowCheckedModeBanner: false,
      // ✅ 设置主题模式
      themeMode: themeState.themeMode,
      // ✅ 亮色主题
      theme: themeState.lightTheme.toThemeData(),
      // ✅ 暗色主题
      darkTheme: themeState.darkTheme.toThemeData(),
      home: const MainScreen(),
    );
  }
}
