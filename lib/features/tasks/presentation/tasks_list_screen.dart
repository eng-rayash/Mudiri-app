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
import '../providers/tasks_provider.dart';

/// Tasks List Screen — displays all active tasks
class TasksListScreen extends ConsumerWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('المهام', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RouteNames.taskCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: tasksState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_rounded, size: 64, color: NeuColors.textHint),
                    AppSpacing.gapMd,
                    Text('لا توجد مهام حالياً', style: AppTypography.body.copyWith(color: NeuColors.textHint)),
                    AppSpacing.gapLg,
                    NeuButton(
                      label: 'إضافة مهمة جديدة',
                      onPressed: () => context.push(RouteNames.taskCreate),
                      icon: Icons.add_rounded,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.screen,
              itemCount: tasks.length,
              separatorBuilder: (context, index) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final priority = Priority.fromValue(task.priority);
                final status = UnifiedStatus.fromValue(task.status);

                return GestureDetector(
                  onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                  child: NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: AppTypography.h4.copyWith(
                                  decoration: status == UnifiedStatus.completed ? TextDecoration.lineThrough : null,
                                  color: status == UnifiedStatus.completed ? NeuColors.textSecondary : null,
                                ),
                              ),
                            ),
                            AppSpacing.gapHSm,
                            PriorityChip(priority: priority),
                          ],
                        ),
                        AppSpacing.gapSm,
                        if (task.dueDate?.isNotEmpty == true) ...[
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: NeuColors.textHint),
                              AppSpacing.gapHSm,
                              Text(task.dueDate!, style: AppTypography.caption),
                              const Spacer(),
                              Text(status.arabicLabel, style: AppTypography.caption.copyWith(
                                color: status == UnifiedStatus.completed ? NeuColors.success : NeuColors.navyMid,
                                fontWeight: FontWeight.bold,
                              )),
                            ],
                          ),
                        ] else ...[
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(status.arabicLabel, style: AppTypography.caption.copyWith(
                              color: status == UnifiedStatus.completed ? NeuColors.success : NeuColors.navyMid,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
