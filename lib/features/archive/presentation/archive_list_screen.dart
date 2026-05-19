import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/archive_repository.dart';

/// Screen displaying the archive documents.
class ArchiveListScreen extends ConsumerStatefulWidget {
  const ArchiveListScreen({super.key});

  @override
  ConsumerState<ArchiveListScreen> createState() => _ArchiveListScreenState();
}

class _ArchiveListScreenState extends ConsumerState<ArchiveListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If search query is empty, watch all, else watch search
    final archiveAsync = _searchQuery.isEmpty 
        ? ref.watch(archiveListProvider)
        : ref.watch(archiveListProvider); // Ideally we'd have a specific provider for search, but for simplicity we will filter locally or call the repo method.
        
    // A better approach for searching via Riverpod is to use a StateProvider for query
    // and a dependent Future/StreamProvider. For now, we will just filter the data locally for UI speed.

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('الأرشيف', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.screen,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الرقم المرجعي...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: NeuColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: archiveAsync.when(
                data: (documents) {
                  // Local filtering
                  final filteredDocs = documents.where((doc) {
                    final q = _searchQuery.toLowerCase();
                    return doc.title.toLowerCase().contains(q) ||
                           (doc.referenceNumber?.toLowerCase().contains(q) ?? false) ||
                           (doc.tags?.toLowerCase().contains(q) ?? false);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد وثائق مؤرشفة مطابقة',
                        style: AppTypography.body.copyWith(color: NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screen,
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NeuCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: doc.isConfidential 
                                      ? NeuColors.priorityCritical.withValues(alpha: 0.1) 
                                      : NeuColors.navyMid.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  doc.isConfidential ? Icons.lock_rounded : Icons.folder_rounded,
                                  color: doc.isConfidential ? NeuColors.priorityCritical : NeuColors.navyDeep,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.title,
                                      style: AppTypography.h3.copyWith(fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (doc.referenceNumber != null && doc.referenceNumber!.isNotEmpty) ...[
                                          const Icon(Icons.tag_rounded, size: 14, color: NeuColors.textHint),
                                          const SizedBox(width: 4),
                                          Text(
                                            doc.referenceNumber!,
                                            style: AppTypography.caption,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        if (doc.documentDate != null && doc.documentDate!.isNotEmpty) ...[
                                          const Icon(Icons.calendar_today_rounded, size: 14, color: NeuColors.textHint),
                                          const SizedBox(width: 4),
                                          Text(
                                            doc.documentDate!,
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('خطأ في جلب الأرشيف: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.archiveCreate),
        backgroundColor: NeuColors.navyDeep,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
