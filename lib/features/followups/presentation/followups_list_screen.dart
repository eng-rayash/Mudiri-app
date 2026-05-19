import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/priority_chip.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../providers/follow_ups_provider.dart';

/// Follow-ups List Screen — displays all active follow-ups with search & filter.
class FollowupsListScreen extends ConsumerStatefulWidget {
  const FollowupsListScreen({super.key});

  @override
  ConsumerState<FollowupsListScreen> createState() =>
      _FollowupsListScreenState();
}

class _FollowupsListScreenState
    extends ConsumerState<FollowupsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'جديد', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'بانتظار الرد', value: '2'),
    FilterOption(label: 'مكتمل', value: '3'),
    FilterOption(label: 'متأخر', value: '4'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final followupsState = ref.watch(followUpsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text('المتابعات',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: isDark
                    ? NeuColors.goldAccent
                    : NeuColors.navyDeep),
            onPressed: () => context.push(RouteNames.followupCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في المتابعات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // Follow-ups List
            Expanded(
              child: followupsState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (followups) {
                  var filtered = followups.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where((f) => f.status == statusVal)
                          .toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((f) {
                      return f.title
                              .toLowerCase()
                              .contains(q) ||
                          (f.notes ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (f.targetDate ?? '').contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded,
                              size: 64,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                          AppSpacing.gapMd,
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _statusFilter != 'all'
                                ? 'لا توجد نتائج مطابقة'
                                : 'لا توجد متابعات حالياً',
                            style: AppTypography.body.copyWith(
                                color: isDark
                                    ? NeuColors.textHintDark
                                    : NeuColors.textHint),
                          ),
                          if (_searchQuery.isEmpty &&
                              _statusFilter == 'all') ...[
                            AppSpacing.gapLg,
                            NeuButton(
                              label: 'إضافة متابعة جديدة',
                              onPressed: () => context.push(
                                  RouteNames.followupCreate),
                              icon: Icons.add_rounded,
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final followup = filtered[index];
                      final priority =
                          Priority.fromValue(followup.priority);
                      final status =
                          UnifiedStatus.fromValue(followup.status);
                      final type = FollowUpEntityType.fromValue(
                          followup.entityType);

                      return NeuCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    followup.title,
                                    style: (isDark
                                            ? AppTypography.h4Dark
                                            : AppTypography.h4)
                                        .copyWith(
                                      decoration: status ==
                                              UnifiedStatus
                                                  .completed
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                      color: status ==
                                              UnifiedStatus
                                                  .completed
                                          ? (isDark
                                              ? NeuColors
                                                  .textSecondaryDark
                                              : NeuColors
                                                  .textSecondary)
                                          : null,
                                    ),
                                  ),
                                ),
                                AppSpacing.gapHSm,
                                PriorityChip(
                                    priority: priority),
                              ],
                            ),
                            AppSpacing.gapSm,
                            Row(
                              children: [
                                Icon(
                                  type ==
                                          FollowUpEntityType
                                              .meeting
                                      ? Icons.groups_rounded
                                      : type ==
                                              FollowUpEntityType
                                                  .directive
                                          ? Icons
                                              .assignment_rounded
                                          : Icons.link_rounded,
                                  size: 14,
                                  color: isDark
                                      ? NeuColors.textHintDark
                                      : NeuColors.textHint,
                                ),
                                AppSpacing.gapHSm,
                                Text(type.arabicLabel,
                                    style: isDark
                                        ? AppTypography
                                            .captionDark
                                        : AppTypography.caption),
                                const Spacer(),
                                Text(
                                  status.arabicLabel,
                                  style: (isDark
                                          ? AppTypography
                                              .captionDark
                                          : AppTypography.caption)
                                      .copyWith(
                                    color: status ==
                                            UnifiedStatus
                                                .completed
                                        ? NeuColors.success
                                        : NeuColors.navyMid,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (followup.targetDate
                                    ?.isNotEmpty ==
                                true) ...[
                              AppSpacing.gapSm,
                              Row(
                                children: [
                                  Icon(
                                      Icons
                                          .calendar_today_rounded,
                                      size: 14,
                                      color: isDark
                                          ? NeuColors
                                              .textHintDark
                                          : NeuColors.textHint),
                                  AppSpacing.gapHSm,
                                  Text(followup.targetDate!,
                                      style: isDark
                                          ? AppTypography
                                              .captionDark
                                          : AppTypography
                                              .caption),
                                ],
                              ),
                            ],
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
}
