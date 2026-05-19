import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/notes_repository.dart';

/// Notes Screen — Phase 4
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('الملاحظات السريعة', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: NeuColors.navyDeep),
            onPressed: () => _showAddNoteDialog(context, ref),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: notesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('لا توجد ملاحظات', style: AppTypography.body));
          }

          return GridView.builder(
            padding: AppSpacing.screen,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title != null && note.title!.isNotEmpty) ...[
                      Text(note.title!, style: AppTypography.h4, maxLines: 1, overflow: TextOverflow.ellipsis),
                      AppSpacing.gapXs,
                    ],
                    Expanded(
                      child: Text(note.content, style: AppTypography.body, overflow: TextOverflow.fade),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger, size: 20),
                        onPressed: () => ref.read(notesRepositoryProvider).deleteNote(note.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeuColors.bgColor,
        title: const Text('ملاحظة جديدة', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان (اختياري)')),
            AppSpacing.gapSm,
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'الملاحظة'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          NeuButton(
            label: 'حفظ',
            onPressed: () {
              if (contentCtrl.text.isNotEmpty) {
                ref.read(notesRepositoryProvider).createNote(
                      title: titleCtrl.text,
                      content: contentCtrl.text,
                    );
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
