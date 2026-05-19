import 'package:drift/drift.dart';

import 'base_table.dart';

/// Archive table — stores metadata for important documents and records.
class Archive extends Table with BaseTableMixin {
  /// Document title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Reference or document number (صادر / وارد)
  TextColumn get referenceNumber => text().nullable()();

  /// Date of the document
  TextColumn get documentDate => text().nullable()();

  /// Category (e.g., Financial, Administrative, Secret)
  TextColumn get category => text().nullable()();

  /// Local file path for offline access
  TextColumn get localFilePath => text().nullable()();

  /// Comma-separated tags for fast search
  TextColumn get tags => text().nullable()();
  
  /// Is highly confidential?
  BoolColumn get isConfidential => boolean().withDefault(const Constant(false))();
}
