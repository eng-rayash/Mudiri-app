import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Archive logic.
class ArchiveRepository {
  ArchiveRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active archive records
  Stream<List<ArchiveData>> watchAll() => _db.archiveDao.watchAllActive();

  /// Search archive
  Stream<List<ArchiveData>> search(String query) => _db.archiveDao.searchArchive(query);

  /// Create a new archive record
  Future<int> createArchiveRecord({
    required String title,
    String? referenceNumber,
    String? documentDate,
    String? category,
    String? localFilePath,
    String? tags,
    bool isConfidential = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.archiveDao.insertDocument(
      ArchiveCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        referenceNumber: drift.Value(referenceNumber),
        documentDate: drift.Value(documentDate),
        category: drift.Value(category),
        localFilePath: drift.Value(localFilePath),
        tags: drift.Value(tags),
        isConfidential: drift.Value(isConfidential),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Always log archive additions
    await _logger.log(SecurityAction.settingsChanged, details: 'أرشفة وثيقة جديدة: $title');
    
    return id;
  }

  /// Record access to confidential document
  Future<void> logConfidentialAccess(String title) async {
    await _logger.log(SecurityAction.settingsChanged, details: 'محاولة وصول لوثيقة سرية: $title');
  }

  /// Delete (soft)
  Future<void> deleteRecord(int id) async {
    await _db.archiveDao.softDelete(id);
    await _logger.logRecordDeleted('وثيقة مؤرشفة', id);
  }
}

/// Provider for ArchiveRepository
final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return ArchiveRepository(db, logger);
});

/// Provider for archive stream
final archiveListProvider = StreamProvider<List<ArchiveData>>((ref) {
  return ref.watch(archiveRepositoryProvider).watchAll();
});
