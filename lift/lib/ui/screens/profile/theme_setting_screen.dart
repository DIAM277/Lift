import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_themes.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    
    // ✅ 获取当前主题
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,  // ✅ 使用主题背景色
      appBar: AppBar(
        title: const Text(
          "主题设置",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,  // ✅ 使用主题卡片色
        elevation: 0,
        actions: [
          // 重置按钮
          TextButton.icon(
            onPressed: () {
              ref.read(themeProvider.notifier).resetTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已重置为默认主题'),
                  backgroundColor: colorScheme.primary,  // ✅ 使用主题主色
                ),
              );
            },
            icon: Icon(Icons.refresh, size: 18, color: colorScheme.primary),  // ✅ 使用主题主色
            label: Text('重置', style: TextStyle(color: colorScheme.primary)),  // ✅ 使用主题主色
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前主题预览
          _buildCurrentThemePreview(context, currentTheme),
          const SizedBox(height: 24),

          // 主题分类：浅色主题
          _buildThemeSection(
            context,
            ref,
            '浅色主题',
            AppThemes.allThemes
                .where((t) => t.brightness == Brightness.light)
                .toList(),
            currentTheme,
            theme,
          ),
          const SizedBox(height: 24),

          // 主题分类：深色主题
          _buildThemeSection(
            context,
            ref,
            '深色主题',
            AppThemes.allThemes
                .where((t) => t.brightness == Brightness.dark)
                .toList(),
            currentTheme,
            theme,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrentThemePreview(BuildContext context, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(theme.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "当前主题",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              theme.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<AppThemeData> themes,
    AppThemeData currentTheme,
    ThemeData theme,  // ✅ 接收主题
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,  // ✅ 使用主题文字色
            ),
          ),
        ),
        ...themes.map(
          (themeData) => _buildThemeCard(
            context,
            ref,
            themeData,
            themeData.id == currentTheme.id,
            theme,  // ✅ 传递主题
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    AppThemeData themeData,
    bool isSelected,
    ThemeData theme,  // ✅ 接收主题
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,  // ✅ 使用主题卡片色
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? themeData.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ref.read(themeProvider.notifier).setTheme(themeData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已切换至「${themeData.name}」主题'),
              duration: const Duration(seconds: 1),
              backgroundColor: themeData.primaryColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 主题图标和颜色预览
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,  // ✅ 使用主题文字色
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeData.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    // 颜色点
                    Row(
                      children: [
                        _buildColorDot(themeData.primaryColor),
                        const SizedBox(width: 6),
                        _buildColorDot(themeData.secondaryColor),
                        const SizedBox(width: 6),
                        _buildColorDot(themeData.backgroundColor),
                      ],
                    ),
                  ],
                ),
              ),
              // 选中标记
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeData.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
    );
  }
}