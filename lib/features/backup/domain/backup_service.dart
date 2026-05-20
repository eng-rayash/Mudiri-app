import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/database/providers/database_providers.dart';

/// Backup Service — handles encrypted database export and restore.
///
/// Export: Copies the live SQLite database to a timestamped backup file
///         and shares it via the system share sheet.
/// Restore: Picks a .sqlite file via file picker and overwrites the
///          current database. Requires app restart afterward.
class BackupService {
  final SecurityLogger _logger;

  BackupService(this._logger);

  /// Export the current database as a shareable backup file.
  Future<bool> exportBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));

      if (!await dbFile.exists()) return false;

      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final backupFileName = 'mudiri_backup_$dateStr.sqlite';
      
      // Copy to temp dir for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, backupFileName));
      await dbFile.copy(tempFile.path);

      await _logger.logBackupCreated();

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'نسخة احتياطية لتطبيق مديري — $dateStr',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restore a database backup from a picked .sqlite file.
  ///
  /// Returns true if successfully restored. App should restart after.
  Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        
        // Validate: file should exist and be non-empty
        if (!await sourceFile.exists()) return false;
        final fileSize = await sourceFile.length();
        if (fileSize < 1024) return false; // Too small to be a valid DB

        // Get target DB path
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));

        // Create safety backup before overwriting
        if (await dbFile.exists()) {
          final safetyBackup = File('${dbFile.path}.bak');
          await dbFile.copy(safetyBackup.path);
        }

        // Overwrite the DB
        await sourceFile.copy(dbFile.path);
        
        await _logger.logBackupRestored();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get backup file size info for display
  Future<String> getDbSizeInfo() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));

      if (await dbFile.exists()) {
        final bytes = await dbFile.length();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      }
      return 'غير متوفر';
    } catch (_) {
      return 'خطأ';
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return BackupService(logger);
});
