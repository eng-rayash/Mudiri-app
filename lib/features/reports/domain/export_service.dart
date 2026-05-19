import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/security/security_logger.dart';
import '../../../core/database/providers/database_providers.dart';
import '../providers/reports_provider.dart';

class ExportService {
  final SecurityLogger _logger;

  ExportService(this._logger);

  Future<void> exportDailyReport(ReportsAnalytics analytics) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final StringBuffer sb = StringBuffer();
      sb.writeln('تقرير مديري اليومي - $dateStr');
      sb.writeln('-----------------------------------');
      sb.writeln('الاجتماعات: ${analytics.totalMeetings}');
      sb.writeln('المهام الإجمالية: ${analytics.totalTasks}');
      sb.writeln('المهام المكتملة: ${analytics.completedTasks}');
      sb.writeln('التوجيهات العاجلة: ${analytics.criticalDirectives}');
      sb.writeln('مواعيد اليوم: ${analytics.upcomingAppointments}');
      sb.writeln('نسبة إنجاز المهام: ${(analytics.taskCompletionRate * 100).toStringAsFixed(1)}%');
      sb.writeln('-----------------------------------');
      sb.writeln('تم إنشاؤه عبر تطبيق مديري للإدارة التنفيذية.');

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/mudiri_report_$dateStr.txt');
      await tempFile.writeAsString(sb.toString());

      await _logger.logDataExport('تقرير يومي (نص)');

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(tempFile.path)], text: 'تقرير مديري اليومي');
    } catch (e) {
      // Handle error
    }
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return ExportService(logger);
});
