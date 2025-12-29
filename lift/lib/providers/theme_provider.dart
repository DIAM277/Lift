import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';

/// 主题状态管理
class ThemeNotifier extends StateNotifier<AppThemeData> {
  static const String _themeKey = 'selected_theme_id';

  ThemeNotifier() : super(AppThemes.defaultTheme) {
    _loadTheme();
  }

  /// 从本地加载主题设置
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_themeKey);
    if (themeId != null) {
      state = AppThemes.getThemeById(themeId);
    }
  }

  /// 切换主题
  Future<void> setTheme(AppThemeData theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.id);
  }

  /// 重置为默认主题
  Future<void> resetTheme() async {
    await setTheme(AppThemes.defaultTheme);
  }
}

/// Provider 定义
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>(
  (ref) => ThemeNotifier(),
);
