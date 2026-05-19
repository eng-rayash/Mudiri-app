import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Follow-up business logic.
class FollowUpsRepository {
  FollowUpsRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active follow-ups
  Stream<List<FollowUp>> watchAll() => _db.followUpsDao.watchAllActive();

  /// Create a new follow-up
  Future<int> createFollowUp({
    required String title,
    required FollowUpEntityType type,
    required Priority priority,
    String? notes,
    String? targetDate,
    int? entityId,
    String? assignedTo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.followUpsDao.insertFollowUp(
      FollowUpsCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        notes: drift.Value(notes),
        targetDate: drift.Value(targetDate),
        entityType: drift.Value(type.value),
        entityId: drift.Value(entityId),
        priority: drift.Value(priority.value),
        status: drift.Value(UnifiedStatus.newItem.value),
        assignedTo: drift.Value(assignedTo),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم إنشاء متابعة جديدة: $title');
    return id;
  }

  /// Update status
  Future<void> updateStatus(int id, UnifiedStatus status) async {
    await _db.followUpsDao.updateStatus(id, status.value);
    await _logger.log(SecurityAction.settingsChanged, details: 'تحديث حالة المتابعة #$id');
  }

  /// Delete (soft)
  Future<void> deleteFollowUp(int id) async {
    await _db.followUpsDao.softDelete(id);
    await _logger.logRecordDeleted('متابعة', id);
  }
}

/// Provider for FollowUpsRepository
final followUpsRepositoryProvider = Provider<FollowUpsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return FollowUpsRepository(db, logger);
});
