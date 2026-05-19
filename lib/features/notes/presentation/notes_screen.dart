import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/notes_repository.dart';

/// Notes Screen — with search across title and content.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesState = ref.watch(notesListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text('الملاحظات السريعة',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded,
                color: isDark
                    ? NeuColors.goldAccent
                    : NeuColors.navyDeep),
            onPressed: () => _showAddNoteDialog(context, ref, isDark),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search
            SearchFilterBar(
              searchHint: 'بحث في الملاحظات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,

            // Notes Grid
            Expanded(
              child: notesState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (notes) {
                  var filtered = notes.toList();

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((n) {
                      return (n.title ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          n.content
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد ملاحظات',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: AppSpacing.screen,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return NeuCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (note.title != null &&
                                note.title!.isNotEmpty) ...[
                              Text(note.title!,
                                  style: isDark
                                      ? AppTypography.h4Dark
                                      : AppTypography.h4,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis),
                              AppSpacing.gapXs,
                            ],
                            Expanded(
                              child: Text(note.content,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                  overflow:
                                      TextOverflow.fade),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color: NeuColors.danger,
                                    size: 20),
                                onPressed: () => ref
                                    .read(
                                        notesRepositoryProvider)
                                    .deleteNote(note.id),
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(),
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
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(
      BuildContext context, WidgetRef ref, bool isDark) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        title: Text('ملاحظة جديدة',
            style: isDark
                ? AppTypography.h3Dark
                : AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'العنوان (اختياري)')),
            AppSpacing.gapSm,
            TextField(
              controller: contentCtrl,
              decoration:
                  const InputDecoration(labelText: 'الملاحظة'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
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
