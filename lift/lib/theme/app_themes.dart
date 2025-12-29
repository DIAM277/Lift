import 'package:flutter/material.dart';

/// 主题模型
class AppThemeData {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Brightness brightness;
  final IconData icon;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.brightness,
    required this.icon,
  });

  /// 生成 Flutter ThemeData
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      // ✅ 使用手动构建的 ColorScheme，确保颜色准确
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor, // ✅ 直接使用我们定义的主色
        onPrimary: Colors.white,
        secondary: secondaryColor, // ✅ 直接使用我们定义的次色
        onSecondary: Colors.white,
        error: const Color(0xFFE74C3C),
        onError: Colors.white,
        surface: cardColor, // ✅ 卡片颜色
        onSurface: textColor, // ✅ 文字颜色
        surfaceContainerHighest: backgroundColor, // ✅ 背景颜色
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dividerColor: brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[800],
      // ✅ 定义文字主题
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textColor),
        displayMedium: TextStyle(color: textColor),
        displaySmall: TextStyle(color: textColor),
        headlineLarge: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
        titleSmall: TextStyle(color: textColor),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textColor),
        labelLarge: TextStyle(color: textColor),
        labelMedium: TextStyle(color: textColor),
        labelSmall: TextStyle(color: textColor),
      ),
    );
  }
}

/// 预定义主题集合
class AppThemes {
  // ✅ 默认蓝色主题 - 保持原来的鲜艳颜色
  static const defaultTheme = AppThemeData(
    id: 'default',
    name: '经典蓝',
    description: '清爽专业的蓝色主题',
    primaryColor: Color(0xFF4F75FF), // ✅ 保持原来的蓝色
    secondaryColor: Color(0xFF6B8FFF), // ✅ 保持原来的浅蓝色
    backgroundColor: Color(0xFFF5F7FA), // ✅ 保持原来的浅灰背景
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    brightness: Brightness.light,
    icon: Icons.water_drop,
  );

  // 活力橙主题
  static const orangeTheme = AppThemeData(
    id: 'orange',
    name: '活力橙',
    description: '充满能量的橙色主题',
    primaryColor: Color(0xFFFF6B35),
    secondaryColor: Color(0xFFFF8C61),
    backgroundColor: Color(0xFFFFF8F5),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    brightness: Brightness.light,
    icon: Icons.local_fire_department,
  );

  // 自然绿主题
  static const greenTheme = AppThemeData(
    id: 'green',
    name: '自然绿',
    description: '清新舒适的绿色主题',
    primaryColor: Color(0xFF2ECC71),
    secondaryColor: Color(0xFF27AE60),
    backgroundColor: Color(0xFFF0F9F4),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    brightness: Brightness.light,
    icon: Icons.eco,
  );

  // 高雅紫主题
  static const purpleTheme = AppThemeData(
    id: 'purple',
    name: '高雅紫',
    description: '优雅神秘的紫色主题',
    primaryColor: Color(0xFF9B59B6),
    secondaryColor: Color(0xFFAF7AC5),
    backgroundColor: Color(0xFFF8F5FA),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    brightness: Brightness.light,
    icon: Icons.star,
  );

  // 深邃红主题
  static const redTheme = AppThemeData(
    id: 'red',
    name: '力量红',
    description: '热情强劲的红色主题',
    primaryColor: Color(0xFFE74C3C),
    secondaryColor: Color(0xFFC0392B),
    backgroundColor: Color(0xFFFFF5F5),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    brightness: Brightness.light,
    icon: Icons.favorite,
  );

  // 暗黑模式
  static const darkTheme = AppThemeData(
    id: 'dark',
    name: '暗夜模式',
    description: '护眼的深色主题',
    primaryColor: Color(0xFF4F75FF),
    secondaryColor: Color(0xFF6B8FFF),
    backgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFE0E0E0),
    brightness: Brightness.dark,
    icon: Icons.dark_mode,
  );

  // AMOLED 纯黑主题
  static const amoledTheme = AppThemeData(
    id: 'amoled',
    name: '纯黑模式',
    description: '适合AMOLED屏幕的纯黑主题',
    primaryColor: Color(0xFF4F75FF),
    secondaryColor: Color(0xFF6B8FFF),
    backgroundColor: Color(0xFF000000),
    cardColor: Color(0xFF0D0D0D),
    textColor: Color(0xFFE0E0E0),
    brightness: Brightness.dark,
    icon: Icons.nightlight,
  );

  /// 所有可用主题列表
  static const List<AppThemeData> allThemes = [
    defaultTheme,
    orangeTheme,
    greenTheme,
    purpleTheme,
    redTheme,
    darkTheme,
    amoledTheme,
  ];

  /// 根据 ID 获取主题
  static AppThemeData getThemeById(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => defaultTheme,
    );
  }
}
