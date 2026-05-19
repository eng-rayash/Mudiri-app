import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/priority_chip.dart';
import '../providers/tasks_provider.dart';
import '../domain/tasks_repository.dart';

/// Task Detail Screen
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('تفاصيل المهمة', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: taskState.valueOrNull != null
                ? () => context.push(RouteNames.taskEditPath(taskId))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: taskState.valueOrNull != null
                ? () => _showMoreOptions(context, ref, taskState.valueOrNull!)
                : null,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (task) {
            if (task == null) {
              return const Center(child: Text('المهمة غير موجودة أو تم حذفها', style: AppTypography.body));
            }

            final status = UnifiedStatus.fromValue(task.status);
            final priority = Priority.fromValue(task.priority);

            return ListView(
              padding: AppSpacing.screen,
              children: [
                NeuCard(
                  showGoldBorder: true,
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTypography.h3.copyWith(
                                decoration: status == UnifiedStatus.completed ? TextDecoration.lineThrough : null,
                                color: status == UnifiedStatus.completed ? NeuColors.textSecondary : null,
                              ),
                            ),
                          ),
                          AppSpacing.gapHSm,
                          PriorityChip(priority: priority),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _buildInfoRow(Icons.info_outline_rounded, 'الحالة', status.arabicLabel),
                      if (task.dueDate?.isNotEmpty == true) ...[
                        AppSpacing.gapSm,
                        _buildInfoRow(Icons.calendar_today_rounded, 'تاريخ التسليم', task.dueDate!),
                      ],
                      if (task.assignedTo?.isNotEmpty == true) ...[
                        AppSpacing.gapSm,
                        _buildInfoRow(Icons.person_outline_rounded, 'المسؤول', task.assignedTo!),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapMd,

                if (task.description?.isNotEmpty == true) ...[
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الوصف', style: AppTypography.h4),
                        AppSpacing.gapSm,
                        Text(task.description!, style: AppTypography.body.copyWith(color: NeuColors.textSecondary)),
                      ],
                    ),
                  ),
                  AppSpacing.gapMd,
                ],
                
                if (status != UnifiedStatus.completed)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeuColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ref.read(tasksRepositoryProvider).updateStatus(taskId, UnifiedStatus.completed);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنجاز المهمة')));
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text('تحديد كمكتمل', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
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

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic task) {
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
                leading: const Icon(Icons.undo_rounded, color: NeuColors.warning),
                title: const Text('إعادة فتح المهمة', style: AppTypography.body),
                onTap: () {
                  ref.read(tasksRepositoryProvider).updateStatus(taskId, UnifiedStatus.inProgress);
                  ctx.pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: NeuColors.danger),
                title: const Text('حذف المهمة', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
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
          title: const Text('حذف المهمة', style: AppTypography.h3),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذه المهمة نهائياً؟', style: AppTypography.body),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('تراجع')),
            TextButton(
              onPressed: () {
                ref.read(tasksRepositoryProvider).deleteTask(taskId);
                ctx.pop();
                context.pop(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المهمة')));
              },
              child: const Text('حذف', style: TextStyle(color: NeuColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
