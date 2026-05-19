import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/neu_search_bar.dart';
import '../../providers/directives_provider.dart';
import '../../widgets/directive_card.dart';

/// Directives List — displays all executive directives with search.
class DirectivesListPage extends ConsumerStatefulWidget {
  const DirectivesListPage({super.key});

  @override
  ConsumerState<DirectivesListPage> createState() =>
      _DirectivesListPageState();
}

class _DirectivesListPageState extends ConsumerState<DirectivesListPage> {
  String _searchQuery = '';

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
            // Search bar
            Padding(
              padding: AppSpacing.screenH,
              child: NeuSearchBar(
                hint: 'بحث في التوجيهات...',
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
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
                  final filtered = _searchQuery.isEmpty
                      ? directives
                      : directives
                          .where((d) =>
                              d.title
                                  .contains(_searchQuery) ||
                              (d.assignedTo ?? '')
                                  .contains(_searchQuery) ||
                              (d.details ?? '')
                                  .contains(_searchQuery))
                          .toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment_rounded,
                      title: 'لا توجد توجيهات',
                      subtitle: 'أضف توجيهًا إداريًا جديدًا',
                      actionLabel: 'إضافة توجيه',
                      onAction: () =>
                          context.push(RouteNames.directiveCreate),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final directive = filtered[index];
                      return DirectiveCard(
                        directive: directive,
                        onTap: () => context.push(
                          RouteNames.directiveDetailPath(directive.id),
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
