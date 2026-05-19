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
import '../providers/tasks_provider.dart';

/// Tasks List Screen — displays all active tasks with search & filter.
class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() =>
      _TasksListScreenState();
}

class _TasksListScreenState
    extends ConsumerState<TasksListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'جديد', value: '0'),
    FilterOption(label: 'قيد التنفيذ', value: '1'),
    FilterOption(label: 'مكتمل', value: '3'),
    FilterOption(label: 'متأخر', value: '4'),
    FilterOption(label: 'ملغي', value: '6'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksState = ref.watch(tasksListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text('المهام',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: isDark
                    ? NeuColors.goldAccent
                    : NeuColors.navyDeep),
            onPressed: () => context.push(RouteNames.taskCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في المهام...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _statusFilter,
              onFilterChanged: (v) =>
                  setState(() => _statusFilter = v),
            ),
            AppSpacing.gapMd,

            // Tasks List
            Expanded(
              child: tasksState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (tasks) {
                  var filtered = tasks.toList();

                  // Status filter
                  if (_statusFilter != 'all') {
                    final statusVal =
                        int.tryParse(_statusFilter);
                    if (statusVal != null) {
                      filtered = filtered
                          .where((t) => t.status == statusVal)
                          .toList();
                    }
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((t) {
                      return t.title
                              .toLowerCase()
                              .contains(q) ||
                          (t.description ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (t.assignedTo ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (t.dueDate ?? '').contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_rounded,
                              size: 64,
                              color: isDark
                                  ? NeuColors.textHintDark
                                  : NeuColors.textHint),
                          AppSpacing.gapMd,
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _statusFilter != 'all'
                                ? 'لا توجد نتائج مطابقة'
                                : 'لا توجد مهام حالياً',
                            style: AppTypography.body.copyWith(
                                color: isDark
                                    ? NeuColors.textHintDark
                                    : NeuColors.textHint),
                          ),
                          if (_searchQuery.isEmpty &&
                              _statusFilter == 'all') ...[
                            AppSpacing.gapLg,
                            NeuButton(
                              label: 'إضافة مهمة جديدة',
                              onPressed: () => context
                                  .push(RouteNames.taskCreate),
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
                      final task = filtered[index];
                      final priority =
                          Priority.fromValue(task.priority);
                      final status =
                          UnifiedStatus.fromValue(task.status);

                      return GestureDetector(
                        onTap: () => context.push(
                            RouteNames.taskDetailPath(task.id)),
                        child: NeuCard(
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
                                      task.title,
                                      style: (isDark
                                              ? AppTypography
                                                  .h4Dark
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
                              if (task.dueDate?.isNotEmpty ==
                                  true) ...[
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
                                    Text(task.dueDate!,
                                        style: isDark
                                            ? AppTypography
                                                .captionDark
                                            : AppTypography
                                                .caption),
                                    const Spacer(),
                                    Text(
                                      status.arabicLabel,
                                      style: (isDark
                                              ? AppTypography
                                                  .captionDark
                                              : AppTypography
                                                  .caption)
                                          .copyWith(
                                        color: status ==
                                                UnifiedStatus
                                                    .completed
                                            ? NeuColors.success
                                            : NeuColors.navyMid,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Align(
                                  alignment: AlignmentDirectional
                                      .centerEnd,
                                  child: Text(
                                    status.arabicLabel,
                                    style: (isDark
                                            ? AppTypography
                                                .captionDark
                                            : AppTypography
                                                .caption)
                                        .copyWith(
                                      color: status ==
                                              UnifiedStatus
                                                  .completed
                                          ? NeuColors.success
                                          : NeuColors.navyMid,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
