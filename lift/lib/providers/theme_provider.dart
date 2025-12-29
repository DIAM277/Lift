import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';

/// 主题状态（包含主题数据和主题模式）
class ThemeState {
  final AppThemeData lightTheme; // 亮色主题
  final AppThemeData darkTheme; // 暗色主题
  final ThemeMode themeMode; // 当前模式

  ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.themeMode,
  });

  ThemeState copyWith({
    AppThemeData? lightTheme,
    AppThemeData? darkTheme,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// 主题状态管理
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _lightThemeKey = 'light_theme_id'; // 亮色主题ID
  static const String _darkThemeKey = 'dark_theme_id'; // 暗色主题ID
  static const String _themeModeKey = 'theme_mode'; // 主题模式

  ThemeNotifier()
    : super(
        ThemeState(
          lightTheme: AppThemes.defaultTheme, // 默认亮色主题
          darkTheme: AppThemes.darkTheme, // 默认暗色主题
          themeMode: ThemeMode.light, // 默认使用亮色模式
        ),
      ) {
    _loadTheme();
  }

  /// 从本地加载主题设置
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载亮色主题
    final lightThemeId = prefs.getString(_lightThemeKey);
    final lightTheme = lightThemeId != null
        ? AppThemes.getThemeById(lightThemeId)
        : AppThemes.defaultTheme;

    // 加载暗色主题
    final darkThemeId = prefs.getString(_darkThemeKey);
    final darkTheme = darkThemeId != null
        ? AppThemes.getThemeById(darkThemeId)
        : AppThemes.darkTheme;

    // 加载主题模式
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final themeMode = ThemeMode.values[themeModeIndex];

    state = ThemeState(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }

  /// 设置亮色主题
  Future<void> setLightTheme(AppThemeData theme) async {
    state = state.copyWith(lightTheme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lightThemeKey, theme.id);
  }

  /// 设置暗色主题
  Future<void> setDarkTheme(AppThemeData theme) async {
    state = state.copyWith(darkTheme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_darkThemeKey, theme.id);
  }

  /// 获取当前主题模式
  ThemeMode get themeMode => state.themeMode;

  /// 判断是否是暗色模式
  bool get isDarkMode {
    if (state.themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }

  /// 切换亮色/暗色模式
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    state = state.copyWith(themeMode: newMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, newMode.index);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;

    state = state.copyWith(themeMode: mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// 重置为默认主题
  Future<void> resetTheme() async {
    state = ThemeState(
      lightTheme: AppThemes.defaultTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.light,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lightThemeKey);
    await prefs.remove(_darkThemeKey);
    await prefs.remove(_themeModeKey);
  }
}

/// Provider 定义
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
