import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/router/route_names.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../timeline/providers/timeline_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/dashboard_fab.dart';
import '../../notifications/domain/notification_service.dart';
import '../../notifications/providers/smart_notifications_provider.dart';
import '../../../core/security/secure_storage_service.dart';

/// Dashboard Screen — executive command center.
///
/// Displays: Today's summary, upcoming meetings, stats overview.
/// Quick-add actions are accessible via the center FAB.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGreeting();
    });
  }

  Future<void> _checkAndShowGreeting() async {
    try {
      final storage = SecureStorageService.instance;
      final notificationsVal = await storage.read('notifications_enabled');
      if (notificationsVal == 'false') return;
      if (!mounted) return;

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastShown = await storage.read('last_greeting_shown_date');
      if (lastShown == todayStr) return; // Already shown today
      if (!mounted) return;

      // Get today's stats
      final analytics = ref.read(reportsAnalyticsProvider);
      final todayMeetings = ref.read(todayMeetingsProvider).valueOrNull?.length ?? 0;
      
      // Trigger notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.showNotification(
        id: 999,
        title: 'صباح الخير سعادة المدير! ☀️',
        body: 'لديك اليوم $todayMeetings اجتماعات، و ${analytics.totalTasks} مهام، و ${analytics.upcomingAppointments} مواعيد قادمة.',
      );

      // Save that we showed it today
      if (!mounted) return;
      await storage.write('last_greeting_shown_date', todayStr);
    } catch (e) {
      debugPrint('Error triggering daily greeting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    
    // Format Gregorian Date
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    
    // Format Hijri Date
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    final analytics = ref.watch(reportsAnalyticsProvider);
    final events = ref.watch(timelineProvider);
    final displayedEvents = events.take(5).toList();

    // Activate and synchronize smart dynamic reminders
    ref.watch(smartNotificationsSchedulerProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      floatingActionButton: const DashboardFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Executive Bar
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
                              'مرحبًا، سعادة المدير',
                              style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              '$dateStr | $hijriStr',
                              style: isDark
                                  ? AppTypography.captionDark.copyWith(
                                      color: NeuColors.goldAccent,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTypography.caption.copyWith(
                                      color: NeuColors.navyMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.settings),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: isDark ? NeuColors.shadowLightDark : NeuColors.shadowLight,
                                offset: const Offset(-3, -3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
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
                            Icon(
                              Icons.calendar_today_rounded,
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                              size: 20,
                            ),
                            AppSpacing.gapHSm,
                            Text(
                              'ملخص اليوم التنفيذي',
                              style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                            ),
                          ],
                        ),
                        AppSpacing.gapLg,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('${RouteNames.meetingsListFull}?filter=today'),
                                child: _buildSummaryItem(
                                  Icons.groups_rounded,
                                  '${ref.watch(todayMeetingsProvider).valueOrNull?.length ?? 0}',
                                  'اجتماعات',
                                  isDark,
                                  NeuColors.info,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('${RouteNames.tasksListFull}?status=all'),
                                child: _buildSummaryItem(
                                  Icons.task_alt_rounded,
                                  '${analytics.totalTasks}',
                                  'مهام عمل',
                                  isDark,
                                  NeuColors.success,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('${RouteNames.directivesList}?filter=critical'),
                                child: _buildSummaryItem(
                                  Icons.campaign_rounded,
                                  '${analytics.criticalDirectives}',
                                  'توجيهات عاجلة',
                                  isDark,
                                  NeuColors.danger,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('${RouteNames.appointmentsList}?filter=today'),
                                child: _buildSummaryItem(
                                  Icons.event_rounded,
                                  '${analytics.upcomingAppointments}',
                                  'مواعيد هامة',
                                  isDark,
                                  NeuColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Task Distribution Donut Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenH,
                  child: TaskDistributionChart(
                    completed: analytics.completedTasks,
                    inProgress: analytics.inProgressTasks,
                    overdue: analytics.overdueTasks,
                    stalled: analytics.stalledTasks,
                    isDark: isDark,
                  ),
                ),
              ),

              // Section: Daily Timeline (السجل الزمني اليومي)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'السجل الزمني اليومي',
                        style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.timeline),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'عرض المخطط',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Timeline List using SliverList.builder
              displayedEvents.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.screenH,
                        child: NeuCard(
                          child: EmptyState(
                            icon: Icons.timeline_rounded,
                            title: 'لا توجد أحداث مجدولة لليوم',
                            actionLabel: 'عرض المخطط الكامل',
                            onAction: () => context.push(RouteNames.timeline),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: AppSpacing.screenH,
                      sliver: SliverList.builder(
                        itemCount: displayedEvents.length,
                        itemBuilder: (context, idx) {
                          final event = displayedEvents[idx];
                          
                          IconData getEventIcon(String type) {
                            switch (type) {
                              case 'meeting': return Icons.groups_rounded;
                              case 'visitor': return Icons.badge_rounded;
                              case 'movement': return Icons.directions_car_rounded;
                              case 'appointment': return Icons.calendar_month_rounded;
                              case 'task': return Icons.task_alt_rounded;
                              case 'call': return Icons.phone_in_talk_rounded;
                              case 'directive': return Icons.campaign_rounded;
                              default: return Icons.event_note_rounded;
                            }
                          }

                          Color getEventColor(String type) {
                            switch (type) {
                              case 'meeting': return NeuColors.info;
                              case 'visitor': return NeuColors.warning;
                              case 'movement': return isDark ? NeuColors.goldAccent : NeuColors.navyMid;
                              case 'appointment': return NeuColors.success;
                              case 'task': return NeuColors.navyLight;
                              case 'call': return NeuColors.info;
                              case 'directive': return NeuColors.danger;
                              default: return NeuColors.goldAccent;
                            }
                          }

                          String getEventTypeName(String type) {
                            switch (type) {
                              case 'meeting': return 'اجتماع';
                              case 'visitor': return 'لقاء / زيارة';
                              case 'movement': return 'تحرك خارجي';
                              case 'appointment': return 'موعد';
                              case 'task': return 'مهمة عمل';
                              case 'call': return 'مكالمة هاتفية';
                              case 'directive': return 'توجيه تنفيذي';
                              default: return 'حدث';
                            }
                          }

                          void handleEventTap(BuildContext context, TimelineEvent event) {
                            if (event.id == null) return;
                            switch (event.type) {
                              case 'meeting':
                                context.push(RouteNames.meetingDetailPath(event.id!));
                                break;
                              case 'task':
                                context.push(RouteNames.taskDetailPath(event.id!));
                                break;
                              case 'directive':
                                context.push(RouteNames.directiveDetailPath(event.id!));
                                break;
                              case 'appointment':
                                context.push(RouteNames.appointmentsList);
                                break;
                              case 'call':
                                context.push(RouteNames.callsList);
                                break;
                              case 'visitor':
                                context.push(RouteNames.visitorsList);
                                break;
                              case 'movement':
                                context.push(RouteNames.movementsList);
                                break;
                            }
                          }

                          final color = getEventColor(event.type);
                          final icon = getEventIcon(event.type);
                          final typeLabel = getEventTypeName(event.type);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time Column
                              SizedBox(
                                width: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    event.time,
                                    style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              
                              // Line & Dot
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 18),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: event.isCompleted ? NeuColors.success : color,
                                      border: Border.all(
                                        color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  if (idx != displayedEvents.length - 1)
                                    Container(
                                      width: 2,
                                      height: 62,
                                      color: isDark ? NeuColors.dividerDark : NeuColors.divider,
                                    ),
                                ],
                              ),
                              
                              AppSpacing.gapHSm,
                              
                              // Card
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => handleEventTap(context, event),
                                    child: NeuCard(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              icon,
                                              color: event.isCompleted ? NeuColors.success : color,
                                              size: 18,
                                            ),
                                          ),
                                          AppSpacing.gapHSm,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.title,
                                                  style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  typeLabel,
                                                  style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (event.isCompleted)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: NeuColors.success,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),



              // Extra padding at bottom for FAB clearance
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSummaryItem(
      IconData icon, String count, String label, bool isDark, Color highlightColor) {
    return Column(
      children: [
        Icon(icon, color: highlightColor, size: 24),
        AppSpacing.gapXs,
        Text(
          count,
          style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: isDark
              ? AppTypography.captionDark.copyWith(fontSize: 11)
              : AppTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

}

/// Task distribution fl_chart section
class TaskDistributionChart extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int overdue;
  final int stalled;
  final bool isDark;

  const TaskDistributionChart({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.overdue,
    required this.stalled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = completed + inProgress + overdue + stalled;

    return NeuCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.donut_large_rounded,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                size: 20,
              ),
              AppSpacing.gapHSm,
              Text(
                'توزيع حالات مهام العمل',
                style: isDark ? AppTypography.h4Dark : AppTypography.h4,
              ),
            ],
          ),
          AppSpacing.gapLg,
          if (total == 0)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'لا توجد مهام عمل مسجلة حتى الآن.',
                  style: isDark ? AppTypography.bodySmallDark : AppTypography.bodySmall,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: NeuColors.success,
                            value: completed.toDouble(),
                            title: completed > 0 ? '$completed' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: NeuColors.warning,
                            value: inProgress.toDouble(),
                            title: inProgress > 0 ? '$inProgress' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: NeuColors.danger,
                            value: overdue.toDouble(),
                            title: overdue > 0 ? '$overdue' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            color: isDark ? NeuColors.navyLight : NeuColors.navyMid,
                            value: stalled.toDouble(),
                            title: stalled > 0 ? '$stalled' : '',
                            radius: 16,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(context, 'مكتملة', completed, NeuColors.success, isDark, () => context.push('${RouteNames.tasksListFull}?status=3')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'قيد التنفيذ', inProgress, NeuColors.warning, isDark, () => context.push('${RouteNames.tasksListFull}?status=1')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'متأخرة', overdue, NeuColors.danger, isDark, () => context.push('${RouteNames.tasksListFull}?status=4')),
                      AppSpacing.gapSm,
                      _buildLegendItem(context, 'متعثرة', stalled, isDark ? NeuColors.navyLight : NeuColors.navyMid, isDark, () => context.push('${RouteNames.tasksListFull}?status=5')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, int count, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapHSm,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Tajawal',
                color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSansArabic',
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
