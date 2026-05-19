import 'package:drift/drift.dart';

import 'base_table.dart';

/// Users table — stores user profile and auth preferences.
///
/// In Phase 1, this is a single-user app. The table is designed
/// to support multi-user scenarios in the future.
class Users extends Table with BaseTableMixin {
  /// Display name shown on dashboard
  TextColumn get displayName => text().withLength(min: 1, max: 100)();

  /// Hashed PIN code (never stored in plain text)
  TextColumn get pinHash => text().nullable()();

  /// Preferred authentication method (biometric=0, pin=1, pattern=2)
  IntColumn get authMethod => integer().withDefault(const Constant(0))();

  /// Whether biometric authentication is enabled
  BoolColumn get isBiometricEnabled =>
      boolean().withDefault(const Constant(false))();

  /// User role (for future multi-user: 0=admin, 1=secretary, 2=viewer)
  IntColumn get role => integer().withDefault(const Constant(0))();

  /// User avatar path (local file)
  TextColumn get avatarPath => text().nullable()();
}
