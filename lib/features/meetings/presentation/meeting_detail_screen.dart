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

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('تفاصيل الاجتماع', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded), 
            onPressed: meetingState.valueOrNull != null 
                ? () => context.push(RouteNames.meetingEditPath(meetingId)) 
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded), 
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
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (meeting) {
            if (meeting == null) {
              return const Center(child: Text('الاجتماع غير موجود أو تم حذفه', style: AppTypography.body));
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
                          Expanded(child: Text(meeting.title, style: AppTypography.h3)),
                          _buildStatusBadge(status),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _buildInfoRow(Icons.calendar_today_rounded, 'التاريخ', meeting.date),
                      AppSpacing.gapSm,
                      _buildInfoRow(Icons.access_time_rounded, 'الوقت', meeting.time),
                      AppSpacing.gapSm,
                      _buildInfoRow(
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
                        const Text('هدف الاجتماع', style: AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(meeting.objective!, style: AppTypography.body.copyWith(color: NeuColors.textSecondary)),
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
                        const Text('ملاحظات', style: AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(meeting.notes!, style: AppTypography.body.copyWith(color: NeuColors.textSecondary)),
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
                      const Text('جدول الأعمال والقرارات', style: AppTypography.h4),
                      AppSpacing.gapSm,
                      Text('سيتم إضافة جدول الأعمال والقرارات في المرحلة القادمة.', style: AppTypography.body.copyWith(color: NeuColors.textHint)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: NeuColors.navyMid),
        AppSpacing.gapHSm,
        Text('$label: ', style: AppTypography.label),
        Expanded(child: Text(value, style: AppTypography.body)),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic meeting) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NeuColors.bgColor,
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
                title: const Text('تحديد كمكتمل', style: AppTypography.body),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.completed);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: NeuColors.warning),
                title: const Text('إلغاء الاجتماع', style: AppTypography.body),
                onTap: () {
                  ref.read(meetingsRepositoryProvider).updateStatus(meetingId, MeetingStatus.cancelled);
                  ctx.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الاجتماع')));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger),
                title: const Text('حذف الاجتماع', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
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
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: NeuColors.bgColor,
          title: const Text('حذف الاجتماع', style: AppTypography.h3),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا الاجتماع نهائياً؟', style: AppTypography.body),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('تراجع')),
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
