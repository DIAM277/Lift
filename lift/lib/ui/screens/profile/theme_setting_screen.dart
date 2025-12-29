import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_themes.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // ✅ 根据当前模式获取对应的主题
    final currentTheme = themeNotifier.isDarkMode
        ? themeState.darkTheme
        : themeState.lightTheme;

    // ✅ 获取可选主题列表（根据当前模式过滤）
    final availableThemes = themeNotifier.isDarkMode
        ? AppThemes.allThemes
              .where((t) => t.brightness == Brightness.dark)
              .toList()
        : AppThemes.allThemes
              .where((t) => t.brightness == Brightness.light)
              .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "主题设置",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题模式切换
          _buildSectionTitle("显示模式", theme),
          const SizedBox(height: 12),
          _buildThemeModeCard(theme, colorScheme, themeState, themeNotifier),
          const SizedBox(height: 24),

          // 主题颜色选择
          _buildSectionTitle(themeNotifier.isDarkMode ? "暗色主题" : "亮色主题", theme),
          const SizedBox(height: 12),
          ...availableThemes.map((themeData) {
            final isSelected = currentTheme.id == themeData.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildThemeCard(
                theme,
                colorScheme,
                themeData,
                isSelected,
                () {
                  if (themeNotifier.isDarkMode) {
                    themeNotifier.setDarkTheme(themeData);
                  } else {
                    themeNotifier.setLightTheme(themeData);
                  }
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          // 重置按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _showResetDialog(context, themeNotifier);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                "重置为默认主题",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildThemeModeCard(
    ThemeData theme,
    ColorScheme colorScheme,
    ThemeState themeState,
    ThemeNotifier themeNotifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
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
        children: [
          _buildThemeModeOption(
            theme,
            colorScheme,
            Icons.light_mode,
            "亮色模式",
            "始终使用亮色主题",
            themeState.themeMode == ThemeMode.light,
            () => themeNotifier.setThemeMode(ThemeMode.light),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildThemeModeOption(
            theme,
            colorScheme,
            Icons.dark_mode,
            "暗色模式",
            "始终使用暗色主题",
            themeState.themeMode == ThemeMode.dark,
            () => themeNotifier.setThemeMode(ThemeMode.dark),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildThemeModeOption(
            theme,
            colorScheme,
            Icons.brightness_auto,
            "跟随系统",
            "根据系统设置自动切换",
            themeState.themeMode == ThemeMode.system,
            () => themeNotifier.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    ThemeData theme,
    ColorScheme colorScheme,
    AppThemeData themeData,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 主题预览色块
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeData.primaryColor, themeData.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(themeData.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // 主题信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeData.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    themeData.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // 选中标记
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[300], size: 28),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "重置主题",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("确定要重置为默认主题吗？"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              themeNotifier.resetTheme();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已重置为默认主题')));
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }
}
