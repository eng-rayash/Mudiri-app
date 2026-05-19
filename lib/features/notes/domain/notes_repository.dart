import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/notes_dao.dart';
import '../../../core/database/providers/database_providers.dart';

/// Repository for Notes — Phase 4
class NotesRepository {
  final NotesDao _dao;
  final _uuid = const Uuid();

  NotesRepository(this._dao);

  Future<void> createNote({
    String? title,
    required String content,
    String? colorCode,
    String? tags,
  }) async {
    final companion = NotesCompanion.insert(
      syncId: _uuid.v4(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      title: Value(title),
      content: content,
      colorCode: Value(colorCode),
      tags: Value(tags),
    );

    await _dao.insertNote(companion);
  }

  Future<void> deleteNote(int id) async {
    await _dao.deleteNoteSoft(id);
  }

  Stream<List<NoteItem>> watchAllNotes() => _dao.watchAllNotes();
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dao = ref.watch(notesDaoProvider);
  return NotesRepository(dao);
});

final notesListProvider = StreamProvider<List<NoteItem>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.watchAllNotes();
});
