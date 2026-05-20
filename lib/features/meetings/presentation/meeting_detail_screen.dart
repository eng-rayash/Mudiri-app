import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/meetings_provider.dart';
import '../domain/meetings_repository.dart';

/// Meeting Detail Screen — full meeting information view.
class MeetingDetailScreen extends ConsumerWidget {
  const MeetingDetailScreen({super.key, required this.meetingId});

  final int meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingState = ref.watch(meetingDetailProvider(meetingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'تفاصيل الاجتماع',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ), 
            onPressed: meetingState.valueOrNull != null 
                ? () => context.push(RouteNames.meetingEditPath(meetingId)) 
                : null,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ), 
            onPressed: meetingState.valueOrNull != null 
                ? () => _showMoreOptions(context, ref, meetingState.valueOrNull!) 
                : null,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: meetingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err', style: isDark ? AppTypography.bodyDark : AppTypography.body)),
          data: (meeting) {
            if (meeting == null) {
              return Center(child: Text('الاجتماع غير موجود أو تم حذفه', style: isDark ? AppTypography.bodyDark : AppTypography.body));
            }

            final status = MeetingStatus.fromValue(meeting.status);

            return ListView(
              padding: AppSpacing.screen,
              children: [
                // Title & Status
                NeuCard(
                  showGoldBorder: true,
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meeting.title, 
                              style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _buildInfoRow(
                        context, 
                        Icons.group_work_rounded, 
                        'النوع', 
                        meeting.customMeetingType ?? MeetingType.fromValue(meeting.meetingType).arabicLabel
                      ),
                      AppSpacing.gapSm,
                      _buildInfoRow(context, Icons.calendar_today_rounded, 'التاريخ', meeting.date),
                      AppSpacing.gapSm,
                      _buildInfoRow(context, Icons.access_time_rounded, 'الوقت', meeting.time),
                      AppSpacing.gapSm,
                      _buildInfoRow(
                        context,
                        Icons.location_on_outlined, 
                        'المكان', 
                        meeting.location?.isNotEmpty == true ? meeting.location! : 'غير محدد'
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapMd,

                // Objective
                if (meeting.objective?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('هدف الاجتماع', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(
                          meeting.objective!, 
                          style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],

                // Notes
                if (meeting.notes?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ملاحظات', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(
                          meeting.notes!, 
                          style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],

                // Placeholder for Agenda & Decisions (Phase 2/3)
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('جدول الأعمال والقرارات', style: isDark ? AppTypography.h4Dark : AppTypography.h4),
                      AppSpacing.gapSm,
                      Text(
                        'سيتم إضافة جدول الأعمال والقرارات في المرحلة القادمة.', 
                        style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXxl,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return StatusBadge.scheduled();
      case MeetingStatus.completed:
        return StatusBadge.completed();
      case MeetingStatus.cancelled:
        return StatusBadge.cancelled();
      default:
        return StatusBadge.scheduled();
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 18, 
          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
        ),
        AppSpacing.gapHSm,
        Text(
          '$label: ', 
          style: isDark ? AppTypography.labelDark : AppTypography.label,
        ),
        Expanded(
          child: Text(
            value, 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic meeting) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: NeuColors.success),
                title: Text(
                  'تحديد كمكتمل', 
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.completed);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: NeuColors.warning),
                title: Text(
                  'إلغاء الاجتماع', 
                  style: isDark ? AppTypography.bodyDark : AppTypography.body,
                ),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.cancelled);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الاجتماع')));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger),
                title: Text(
                  'حذف الاجتماع', 
                  style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                    color: NeuColors.danger, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  ctx.pop();
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          title: Text(
            'حذف الاجتماع', 
            style: isDark ? AppTypography.h3Dark : AppTypography.h3,
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا الاجتماع نهائياً؟', 
            style: isDark ? AppTypography.bodyDark : AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(), 
              child: Text(
                'تراجع',
                style: TextStyle(
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  fontFamily: AppTypography.fontFamilyBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(meetingsRepositoryProvider).deleteMeeting(meetingId);
                ctx.pop();
                context.pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الاجتماع بنجاح')));
              },
              child: const Text('حذف', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
