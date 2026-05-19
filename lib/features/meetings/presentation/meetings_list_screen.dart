import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/meetings_provider.dart';

/// Meetings List Screen — displays all meetings with search & filter.
class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() =>
      _MeetingsListScreenState();
}

class _MeetingsListScreenState
    extends ConsumerState<MeetingsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'مجدول', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'مكتمل', value: '2'),
    FilterOption(label: 'مؤجل', value: '3'),
    FilterOption(label: 'ملغي', value: '4'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Header
              Padding(
                padding: AppSpacing.screen,
                child: Row(
                  children: [
                    Text('الاجتماعات',
                        style: isDark
                            ? AppTypography.h2Dark
                            : AppTypography.h2),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          context.push(RouteNames.meetingCreate),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? NeuColors.surfaceDark
                              : NeuColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyDeep,
                            size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // Search & Filter
              SearchFilterBar(
                searchHint: 'بحث في الاجتماعات...',
                onSearchChanged: (q) =>
                    setState(() => _searchQuery = q),
                filters: _filters,
                selectedFilter: _statusFilter,
                onFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
              ),

              AppSpacing.gapMd,

              // Meeting List
              Expanded(
                child: ref.watch(meetingsListProvider).when(
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                      child: Text('حدث خطأ: $err',
                          style: AppTypography.bodySmall
                              .copyWith(color: NeuColors.danger))),
                  data: (meetings) {
                    // Apply filters
                    var filtered = meetings;

                    // Status filter
                    if (_statusFilter != 'all') {
                      final statusVal =
                          int.tryParse(_statusFilter);
                      if (statusVal != null) {
                        filtered = filtered
                            .where(
                                (m) => m.status == statusVal)
                            .toList();
                      }
                    }

                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((m) {
                        return m.title
                                .toLowerCase()
                                .contains(q) ||
                            (m.location ?? '')
                                .toLowerCase()
                                .contains(q) ||
                            (m.objective ?? '')
                                .toLowerCase()
                                .contains(q) ||
                            (m.notes ?? '')
                                .toLowerCase()
                                .contains(q) ||
                            m.date.contains(q);
                      }).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined,
                                size: 64,
                                color: (isDark
                                        ? NeuColors.textHintDark
                                        : NeuColors.textHint)
                                    .withAlpha(120)),
                            AppSpacing.gapLg,
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _statusFilter != 'all'
                                  ? 'لا توجد نتائج مطابقة'
                                  : 'لا توجد اجتماعات',
                              style: (isDark
                                      ? AppTypography.h4Dark
                                      : AppTypography.h4)
                                  .copyWith(
                                      color: isDark
                                          ? NeuColors
                                              .textHintDark
                                          : NeuColors.textHint),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final meeting = filtered[index];
                        return GestureDetector(
                          onTap: () => context.push(
                              RouteNames.meetingDetailPath(
                                  meeting.id)),
                          child: NeuCard(
                            margin:
                                const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        meeting.title,
                                        style: isDark
                                            ? AppTypography.h4Dark
                                            : AppTypography.h4,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge
                                        .fromMeetingStatus(
                                            meeting.status),
                                  ],
                                ),
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
                                            : NeuColors.navyMid),
                                    AppSpacing.gapHSm,
                                    Text(meeting.date,
                                        style: isDark
                                            ? AppTypography
                                                .captionDark
                                            : AppTypography
                                                .caption),
                                    AppSpacing.gapHMd,
                                    Icon(
                                        Icons
                                            .access_time_rounded,
                                        size: 14,
                                        color: isDark
                                            ? NeuColors
                                                .textHintDark
                                            : NeuColors.navyMid),
                                    AppSpacing.gapHSm,
                                    Text(meeting.time,
                                        style: isDark
                                            ? AppTypography
                                                .captionDark
                                            : AppTypography
                                                .caption),
                                    if (meeting.location !=
                                            null &&
                                        meeting.location!
                                            .isNotEmpty) ...[
                                      AppSpacing.gapHMd,
                                      Icon(
                                          Icons
                                              .location_on_rounded,
                                          size: 14,
                                          color: isDark
                                              ? NeuColors
                                                  .textHintDark
                                              : NeuColors
                                                  .navyMid),
                                      AppSpacing.gapHSm,
                                      Expanded(
                                        child: Text(
                                            meeting.location!,
                                            style: isDark
                                                ? AppTypography
                                                    .captionDark
                                                : AppTypography
                                                    .caption,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
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
      ),
      floatingActionButton: GestureDetector(
        onTap: () => context.push(RouteNames.meetingCreate),
        child: Container(
          width: 56,
          height: 56,
          decoration: NeuDecorations.neuFlat(
              radius: 50, isDark: isDark),
          child: const Icon(Icons.add_rounded,
              color: NeuColors.goldAccent, size: 28),
        ),
      ),
    );
  }
}
