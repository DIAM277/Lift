import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../../../data/isar_service.dart';
import '../../../data/models/workout.dart';
import '../../../data/models/routine.dart';
import '../../../services/export_service.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isLoading = true;
  int _workoutCount = 0;
  int _routineCount = 0;
  bool _isExporting = false;
  String? _lastExportPath;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final isar = await IsarService().db;
    final workouts = await isar.workoutSessions.where().findAll();
    final routines = await isar.workoutRoutines.where().findAll();

    setState(() {
      _workoutCount = workouts.length;
      _routineCount = routines.length;
      _isLoading = false;
    });
  }

  Future<void> _exportWorkoutsCSV() async {
    setState(() => _isExporting = true);

    try {
      final isar = await IsarService().db;
      final sessions = await isar.workoutSessions
          .filter()
          .statusEqualTo('completed')
          .sortByStartTimeDesc()
          .findAll();

      if (sessions.isEmpty) {
        _showMessage('没有训练记录可以导出', isError: true);
        return;
      }

      final filePath = await ExportService.exportWorkoutsToCSV(sessions);
      setState(() {
        _lastExportPath = filePath;
      });
      _showSuccessDialog('CSV 导出成功', filePath);
    } catch (e) {
      _showMessage('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportWorkoutsJSON() async {
    setState(() => _isExporting = true);

    try {
      final isar = await IsarService().db;
      final sessions = await isar.workoutSessions
          .where()
          .sortByStartTimeDesc()
          .findAll();

      if (sessions.isEmpty) {
        _showMessage('没有数据可以导出', isError: true);
        return;
      }

      final filePath = await ExportService.exportWorkoutsToJSON(sessions);
      setState(() {
        _lastExportPath = filePath;
      });
      _showSuccessDialog('JSON 导出成功', filePath);
    } catch (e) {
      _showMessage('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportRoutinesJSON() async {
    setState(() => _isExporting = true);

    try {
      final isar = await IsarService().db;
      final routines = await isar.workoutRoutines.where().findAll();

      if (routines.isEmpty) {
        _showMessage('没有动作组合可以导出', isError: true);
        return;
      }

      final filePath = await ExportService.exportRoutinesToJSON(routines);
      setState(() {
        _lastExportPath = filePath;
      });
      _showSuccessDialog('动作组合导出成功', filePath);
    } catch (e) {
      _showMessage('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);

    try {
      final isar = await IsarService().db;
      final sessions = await isar.workoutSessions.where().findAll();
      final routines = await isar.workoutRoutines.where().findAll();

      if (sessions.isEmpty && routines.isEmpty) {
        _showMessage('没有数据可以导出', isError: true);
        return;
      }

      final filePath = await ExportService.exportAllData(sessions, routines);
      setState(() {
        _lastExportPath = filePath;
      });
      _showSuccessDialog('完整备份导出成功', filePath);
    } catch (e) {
      _showMessage('导出失败: $e', isError: true);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _showSuccessDialog(String title, String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "文件已保存到:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      filePath,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: filePath));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('路径已复制到剪贴板')),
                      );
                    },
                    tooltip: '复制路径',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "你可以通过文件管理器访问此文件",
                      style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "导出数据",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 数据统计卡片
                _buildStatsCard(),
                const SizedBox(height: 24),

                // 最近导出的文件
                if (_lastExportPath != null) ...[
                  _buildLastExportCard(),
                  const SizedBox(height: 24),
                ],

                // 导出选项
                _buildSectionTitle("训练记录"),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.table_chart,
                  title: "导出为 CSV",
                  subtitle: "适合用 Excel 分析，包含已完成的训练",
                  color: Colors.green,
                  onTap: _isExporting ? null : _exportWorkoutsCSV,
                ),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.code,
                  title: "导出为 JSON",
                  subtitle: "结构化数据，包含所有训练记录（含计划）",
                  color: Colors.blue,
                  onTap: _isExporting ? null : _exportWorkoutsJSON,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle("动作组合"),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.folder_open,
                  title: "导出动作组合",
                  subtitle: "导出所有自定义的动作组合模板",
                  color: Colors.orange,
                  onTap: _isExporting ? null : _exportRoutinesJSON,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle("完整备份"),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.backup,
                  title: "导出所有数据",
                  subtitle: "包含训练记录、计划和动作组合的完整备份",
                  color: const Color(0xFF4F75FF),
                  onTap: _isExporting ? null : _exportAllData,
                  isPrimary: true,
                ),

                const SizedBox(height: 24),

                // 说明文字
                _buildInfoCard(),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F75FF), Color(0xFF6B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F75FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.fitness_center, "$_workoutCount", "训练记录"),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.folder, "$_routineCount", "动作组合"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildLastExportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "上次导出的文件",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _lastExportPath!));
                  _showMessage('路径已复制到剪贴板');
                },
                tooltip: '复制路径',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _lastExportPath!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (_isExporting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "关于导出的文件",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "• 文件保存在应用的 Documents 目录\n"
                  "• 可通过文件管理器访问\n"
                  "• CSV 文件可用 Excel 或 WPS 打开\n"
                  "• JSON 文件适合备份和数据迁移",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
