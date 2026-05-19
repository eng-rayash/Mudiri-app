import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/calls_repository.dart';

/// Calls List Screen — with search & filter by call type.
class CallsListScreen extends ConsumerStatefulWidget {
  const CallsListScreen({super.key});

  @override
  ConsumerState<CallsListScreen> createState() =>
      _CallsListScreenState();
}

class _CallsListScreenState
    extends ConsumerState<CallsListScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(
        label: 'واردة', value: '0', icon: Icons.call_received_rounded),
    FilterOption(
        label: 'صادرة', value: '1', icon: Icons.call_made_rounded),
    FilterOption(
        label: 'فائتة', value: '2', icon: Icons.call_missed_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final callsState = ref.watch(callsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text('سجل المكالمات',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_ic_call_rounded,
                color: isDark
                    ? NeuColors.goldAccent
                    : NeuColors.navyDeep),
            onPressed: () => _showAddCallModal(context, ref, isDark),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في المكالمات...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _typeFilter,
              onFilterChanged: (v) =>
                  setState(() => _typeFilter = v),
            ),
            AppSpacing.gapMd,

            // Calls List
            Expanded(
              child: callsState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('خطأ: $err')),
                data: (calls) {
                  var filtered = calls.toList();

                  // Type filter
                  if (_typeFilter != 'all') {
                    final typeVal =
                        int.tryParse(_typeFilter);
                    if (typeVal != null) {
                      filtered = filtered
                          .where(
                              (c) => c.callType == typeVal)
                          .toList();
                    }
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((c) {
                      return c.callerName
                              .toLowerCase()
                              .contains(q) ||
                          (c.summary ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          c.date.contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ||
                                _typeFilter != 'all'
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد مكالمات مسجلة',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.gapMd,
                    itemBuilder: (context, index) {
                      final call = filtered[index];
                      return NeuCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _buildCallIcon(
                                call.callType, isDark),
                            AppSpacing.gapHMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            call.callerName,
                                            style: isDark
                                                ? AppTypography
                                                    .h4Dark
                                                : AppTypography
                                                    .h4),
                                      ),
                                      if (call.isImportant) ...[
                                        AppSpacing.gapHSm,
                                        const Icon(
                                            Icons.star_rounded,
                                            color: NeuColors
                                                .goldAccent,
                                            size: 16),
                                      ],
                                    ],
                                  ),
                                  AppSpacing.gapXs,
                                  Text(
                                      '${call.date} - ${call.time}',
                                      style: isDark
                                          ? AppTypography
                                              .captionDark
                                          : AppTypography
                                              .caption),
                                  if (call.summary != null &&
                                      call.summary!
                                          .isNotEmpty) ...[
                                    AppSpacing.gapXs,
                                    Text(call.summary!,
                                        style: isDark
                                            ? AppTypography
                                                .bodySmallDark
                                            : AppTypography
                                                .bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow
                                            .ellipsis),
                                  ],
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildCallIcon(int type, bool isDark) {
    IconData icon;
    Color color;
    switch (type) {
      case 0:
        icon = Icons.call_received_rounded;
        color = NeuColors.success;
        break;
      case 1:
        icon = Icons.call_made_rounded;
        color = NeuColors.info;
        break;
      default:
        icon = Icons.call_missed_rounded;
        color = NeuColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color:
                  isDark ? NeuColors.shadowDarkDark : NeuColors.shadowDark,
              offset: const Offset(3, 3),
              blurRadius: 6),
          BoxShadow(
              color: isDark
                  ? NeuColors.shadowLightDark
                  : NeuColors.shadowLight,
              offset: const Offset(-3, -3),
              blurRadius: 6),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _showAddCallModal(
      BuildContext context, WidgetRef ref, bool isDark) {
    final nameCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    int selectedType = 0;
    bool isImportant = false;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تسجيل مكالمة جديدة',
                    style: isDark
                        ? AppTypography.h3Dark
                        : AppTypography.h3),
                AppSpacing.gapLg,
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'اسم المتصل',
                      border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                TextField(
                  controller: summaryCtrl,
                  decoration: const InputDecoration(
                      labelText: 'ملخص المكالمة',
                      border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                DropdownButtonFormField<int>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(
                        value: 0,
                        child: Text('مكالمة واردة')),
                    DropdownMenuItem(
                        value: 1,
                        child: Text('مكالمة صادرة')),
                    DropdownMenuItem(
                        value: 2,
                        child: Text('مكالمة فائتة')),
                  ],
                  onChanged: (val) => setModalState(
                      () => selectedType = val ?? 0),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                SwitchListTile(
                  title: Text('مكالمة هامة',
                      style: isDark
                          ? AppTypography.bodyDark
                          : AppTypography.body),
                  value: isImportant,
                  onChanged: (val) =>
                      setModalState(() => isImportant = val),
                  activeTrackColor: NeuColors.goldAccent,
                  activeThumbColor: NeuColors.navyDeep,
                ),
                AppSpacing.gapLg,
                SizedBox(
                  width: double.infinity,
                  child: NeuButton(
                    label: 'حفظ المكالمة',
                    onPressed: () {
                      if (nameCtrl.text.isEmpty) return;
                      final now = DateTime.now();
                      ref
                          .read(callsRepositoryProvider)
                          .logCall(
                            callerName: nameCtrl.text,
                            callType: selectedType,
                            date:
                                '${now.year}-${now.month}-${now.day}',
                            time:
                                '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                            summary: summaryCtrl.text,
                            isImportant: isImportant,
                          );
                      ctx.pop();
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
