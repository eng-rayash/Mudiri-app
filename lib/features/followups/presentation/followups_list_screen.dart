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
import '../providers/follow_ups_provider.dart';

/// Follow-ups List Screen — displays all active follow-ups
class FollowupsListScreen extends ConsumerWidget {
  const FollowupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followupsState = ref.watch(followUpsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('المتابعات', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RouteNames.followupCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: followupsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (followups) {
            if (followups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, size: 64, color: NeuColors.textHint),
                    AppSpacing.gapMd,
                    Text('لا توجد متابعات حالياً', style: AppTypography.body.copyWith(color: NeuColors.textHint)),
                    AppSpacing.gapLg,
                    NeuButton(
                      label: 'إضافة متابعة جديدة',
                      onPressed: () => context.push(RouteNames.followupCreate),
                      icon: Icons.add_rounded,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.screen,
              itemCount: followups.length,
              separatorBuilder: (context, index) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final followup = followups[index];
                final priority = Priority.fromValue(followup.priority);
                final status = UnifiedStatus.fromValue(followup.status);
                final type = FollowUpEntityType.fromValue(followup.entityType);

                return NeuCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              followup.title,
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
                      Row(
                        children: [
                          Icon(
                            type == FollowUpEntityType.meeting ? Icons.groups_rounded : 
                            type == FollowUpEntityType.directive ? Icons.assignment_rounded : 
                            Icons.link_rounded, 
                            size: 14, 
                            color: NeuColors.textHint
                          ),
                          AppSpacing.gapHSm,
                          Text(type.arabicLabel, style: AppTypography.caption),
                          const Spacer(),
                          if (status != UnifiedStatus.completed)
                            GestureDetector(
                              onTap: () {
                                // For MVP, completing directly from the list is easier.
                              },
                              child: Text('إكمال', style: AppTypography.caption.copyWith(
                                color: NeuColors.success,
                                fontWeight: FontWeight.bold,
                              )),
                            )
                          else
                            Text('مكتمل', style: AppTypography.caption.copyWith(
                              color: NeuColors.textHint,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      if (followup.targetDate?.isNotEmpty == true) ...[
                        AppSpacing.gapSm,
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: NeuColors.textHint),
                            AppSpacing.gapHSm,
                            Text(followup.targetDate!, style: AppTypography.caption),
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
    );
  }
}
