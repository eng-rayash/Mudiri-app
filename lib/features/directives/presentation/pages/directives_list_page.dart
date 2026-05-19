import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/search_filter_bar.dart';
import '../../providers/directives_provider.dart';
import '../../widgets/directive_card.dart';

/// Directives List — displays all executive directives with search & filter.
class DirectivesListPage extends ConsumerStatefulWidget {
  const DirectivesListPage({super.key});

  @override
  ConsumerState<DirectivesListPage> createState() =>
      _DirectivesListPageState();
}

class _DirectivesListPageState extends ConsumerState<DirectivesListPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'جديد', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'مكتمل', value: '3'),
    FilterOption(label: 'متأخر', value: '4'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final directivesAsync = ref.watch(directivesListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'التوجيهات الإدارية',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
            onPressed: () => context.push(RouteNames.directiveCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في التوجيهات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // List
            Expanded(
              child: directivesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (directives) {
                  var filtered = directives.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where((d) => d.status == statusVal)
                          .toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((d) {
                      return d.title
                              .toLowerCase()
                              .contains(q) ||
                          (d.assignedTo ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (d.details ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment_rounded,
                      title: _searchQuery.isNotEmpty ||
                              _statusFilter != 'all'
                          ? 'لا توجد نتائج مطابقة'
                          : 'لا توجد توجيهات',
                      subtitle: _searchQuery.isEmpty &&
                              _statusFilter == 'all'
                          ? 'أضف توجيهًا إداريًا جديدًا'
                          : null,
                      actionLabel: _searchQuery.isEmpty &&
                              _statusFilter == 'all'
                          ? 'إضافة توجيه'
                          : null,
                      onAction: _searchQuery.isEmpty &&
                              _statusFilter == 'all'
                          ? () => context.push(
                              RouteNames.directiveCreate)
                          : null,
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final directive = filtered[index];
                      return DirectiveCard(
                        directive: directive,
                        onTap: () => context.push(
                          RouteNames.directiveDetailPath(
                              directive.id),
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
}
