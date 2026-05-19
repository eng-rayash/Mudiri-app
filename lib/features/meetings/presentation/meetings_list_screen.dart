import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/meetings_provider.dart';

/// Meetings List Screen — displays all meetings with filters.
class MeetingsListScreen extends ConsumerWidget {
  const MeetingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NeuColors.bgColor,
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
                    const Text('الاجتماعات', style: AppTypography.h2),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.search_rounded, color: NeuColors.navyDeep),
                    ),
                    AppSpacing.gapHLg,
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.filter_list_rounded, color: NeuColors.navyDeep),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('الكل', true),
                    _buildFilterChip('مجدول', false),
                    _buildFilterChip('مكتمل', false),
                    _buildFilterChip('مؤجل', false),
                    _buildFilterChip('ملغي', false),
                  ],
                ),
              ),

              AppSpacing.gapMd,

              // Meeting List
              Expanded(
                child: ref.watch(meetingsListProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('حدث خطأ: $err', style: AppTypography.bodySmall.copyWith(color: NeuColors.danger))),
                  data: (meetings) {
                    if (meetings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined, size: 64, color: NeuColors.textHint.withValues(alpha: 0.5)),
                            AppSpacing.gapLg,
                            Text('لا توجد اجتماعات', style: AppTypography.h4.copyWith(color: NeuColors.textHint)),
                            AppSpacing.gapSm,
                            Text('ابدأ بإضافة اجتماعك الأول', style: AppTypography.body.copyWith(color: NeuColors.textHint)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return GestureDetector(
                          onTap: () => context.push(RouteNames.meetingDetailPath(meeting.id)),
                          child: NeuCard(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(meeting.title, style: AppTypography.h4, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    StatusBadge.fromMeetingStatus(meeting.status),
                                  ],
                                ),
                                AppSpacing.gapSm,
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 14, color: NeuColors.navyMid),
                                    AppSpacing.gapHSm,
                                    Text(meeting.date, style: AppTypography.caption),
                                    AppSpacing.gapHMd,
                                    Icon(Icons.access_time_rounded, size: 14, color: NeuColors.navyMid),
                                    AppSpacing.gapHSm,
                                    Text(meeting.time, style: AppTypography.caption),
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
          width: 56, height: 56,
          decoration: NeuDecorations.neuFlat(radius: 50),
          child: const Icon(Icons.add_rounded, color: NeuColors.goldAccent, size: 28),
        ),
      ),
    );
  }

  static Widget _buildFilterChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? NeuColors.navyDeep : NeuColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: selected ? NeuColors.textOnDark : NeuColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
