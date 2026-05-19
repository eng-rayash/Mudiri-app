import 'package:drift/drift.dart';

import 'base_table.dart';

/// Follow-ups table — tracks continuous actions on items.
///
/// Used to track follow-ups on meetings, tasks, or directives.
class FollowUps extends Table with BaseTableMixin {
  /// Follow-up title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Follow-up description / notes
  TextColumn get notes => text().nullable()();

  /// Target date for the follow-up (ISO 8601 string)
  TextColumn get targetDate => text().nullable()();

  /// Type of entity being followed up (0=Meeting, 1=Task, 2=Directive)
  IntColumn get entityType => integer().withDefault(const Constant(0))();

  /// ID of the entity being followed up
  IntColumn get entityId => integer().nullable()();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// Status using UnifiedStatus
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Assigned entity/person handling the follow-up
  TextColumn get assignedTo => text().nullable()();
}
