import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/router/route_names.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/empty_state.dart';

/// Dashboard Screen — executive command center.
///
/// Displays: Today's summary, quick actions (2 rows of 4),
/// upcoming meetings, stats overview.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحبًا، المدير',
                              style: isDark
                                  ? AppTypography.h3Dark
                                  : AppTypography.h3,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              dateStr,
                              style: isDark
                                  ? AppTypography.captionDark
                                  : AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.settings),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? NeuColors.bgColorDark
                                : NeuColors.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyDeep,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Today Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: NeuCard(
                    showGoldBorder: true,
                    radius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: NeuColors.goldAccent, size: 20),
                            AppSpacing.gapHSm,
                            Text(
                              'ملخص اليوم',
                              style: isDark
                                  ? AppTypography.h4Dark
                                  : AppTypography.h4,
                            ),
                          ],
                        ),
                        AppSpacing.gapLg,
                        Consumer(builder: (context, ref, child) {
                          final analytics =
                              ref.watch(reportsAnalyticsProvider);
                          return Row(
                            children: [
                              _buildSummaryItem(
                                Icons.groups_rounded,
                                '${ref.watch(todayMeetingsProvider).valueOrNull?.length ?? 0}',
                                'اجتماعات',
                                isDark,
                              ),
                              _buildSummaryItem(
                                Icons.task_alt_rounded,
                                '${analytics.totalTasks}',
                                'مهام',
                                isDark,
                              ),
                              _buildSummaryItem(
                                Icons.replay_rounded,
                                '${analytics.criticalDirectives}',
                                'توجيهات عاجلة',
                                isDark,
                              ),
                              _buildSummaryItem(
                                Icons.event_rounded,
                                '${analytics.upcomingAppointments}',
                                'مواعيد',
                                isDark,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions — 2 rows of 4
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Row 1: اجتماع، لقاء، موعد، زائر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(
                            context,
                            Icons.groups_rounded,
                            'اجتماع',
                            NeuColors.navyDeep,
                            isDark,
                            () => context.push(RouteNames.meetingCreate),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.handshake_rounded,
                            'لقاء',
                            NeuColors.navyMid,
                            isDark,
                            () => context.push(RouteNames.appointmentCreate),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.calendar_month_rounded,
                            'موعد',
                            NeuColors.info,
                            isDark,
                            () => context.push(RouteNames.appointmentCreate),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.person_add_alt_1_rounded,
                            'زائر',
                            NeuColors.success,
                            isDark,
                            () => context.push(RouteNames.visitorsList),
                          ),
                        ],
                      ),
                      AppSpacing.gapMd,
                      // Row 2: مهمة، توجيه، اتصال، ملاحظة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(
                            context,
                            Icons.task_alt_rounded,
                            'مهمة',
                            NeuColors.warning,
                            isDark,
                            () => context.push(RouteNames.taskCreate),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.assignment_rounded,
                            'توجيه',
                            NeuColors.danger,
                            isDark,
                            () => context.push(RouteNames.directiveCreate),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.phone_rounded,
                            'اتصال',
                            NeuColors.goldAccent,
                            isDark,
                            () => context.push(RouteNames.callsList),
                          ),
                          _buildQuickAction(
                            context,
                            Icons.note_add_rounded,
                            'ملاحظة',
                            NeuColors.navyLight,
                            isDark,
                            () => context.push(RouteNames.notesList),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Section: Upcoming Meetings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'الاجتماعات القادمة',
                        style: isDark
                            ? AppTypography.h4Dark
                            : AppTypography.h4,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            context.go(RouteNames.meetingsListFull),
                        child: Text(
                          'عرض الكل',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Upcoming meetings list
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: ref.watch(upcomingMeetingsProvider).when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (err, _) => const Center(
                        child: Text('خطأ في جلب الاجتماعات')),
                    data: (meetings) {
                      if (meetings.isEmpty) {
                        return NeuCard(
                          child: EmptyState(
                            icon: Icons.event_available_rounded,
                            title: 'لا توجد اجتماعات قادمة',
                            actionLabel: 'إضافة اجتماع',
                            onAction: () =>
                                context.push(RouteNames.meetingCreate),
                          ),
                        );
                      }

                      return Column(
                        children: meetings.map((meeting) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => context.push(
                                  RouteNames.meetingDetailPath(
                                      meeting.id)),
                              child: NeuCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? NeuColors.goldAccent
                                            : NeuColors.navyMid,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    AppSpacing.gapHSm,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meeting.title,
                                            style: isDark
                                                ? AppTypography.bodyDark
                                                : AppTypography.body,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${meeting.date} - ${meeting.time}',
                                            style: isDark
                                                ? AppTypography.captionDark
                                                : AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),

              // Stats Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Consumer(builder: (context, ref, child) {
                    final analytics =
                        ref.watch(reportsAnalyticsProvider);
                    final completionRate =
                        (analytics.taskCompletionRate * 100).toInt();

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${ref.watch(meetingsListProvider).valueOrNull?.length ?? 0}',
                            'اجتماعات',
                            NeuColors.info,
                            isDark,
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: _buildStatCard(
                            '$completionRate%',
                            'إنجاز',
                            NeuColors.success,
                            isDark,
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: _buildStatCard(
                            '${analytics.criticalDirectives}',
                            'توجيهات',
                            NeuColors.warning,
                            isDark,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSummaryItem(
      IconData icon, String count, String label, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
              size: 22),
          AppSpacing.gapXs,
          Text(count,
              style: isDark ? AppTypography.h4Dark : AppTypography.h4),
          Text(label,
              style: isDark
                  ? AppTypography.captionDark
                  : AppTypography.caption),
        ],
      ),
    );
  }

  static Widget _buildQuickAction(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuCard(
            padding: const EdgeInsets.all(14),
            margin: EdgeInsets.zero,
            radius: 16,
            child: Icon(icon, color: color, size: 24),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: (isDark
                    ? AppTypography.captionDark
                    : AppTypography.caption)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatCard(
      String value, String label, Color color, bool isDark) {
    return NeuCard(
      margin: EdgeInsets.zero,
      padding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      radius: 20,
      child: Column(
        children: [
          Text(
            value,
            style: (isDark
                    ? AppTypography.statNumberDark
                    : AppTypography.statNumber)
                .copyWith(color: color, fontSize: 24),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: isDark
                ? AppTypography.statLabel
                    .copyWith(color: NeuColors.textSecondaryDark)
                : AppTypography.statLabel,
          ),
        ],
      ),
    );
  }
}
