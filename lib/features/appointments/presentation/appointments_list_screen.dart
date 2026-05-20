import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/appointments_repository.dart';
import '../../../shared/widgets/export_button.dart';
import '../../reports/domain/export_service.dart';

/// Screen displaying the list of appointments with search & filter.
class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  ConsumerState<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState
    extends ConsumerState<AppointmentsListScreen> {
  String _searchQuery = '';
  final Set<int> _selectedIds = {};

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentsAsync = ref.watch(appointmentsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: _selectedIds.isEmpty,
        leading: _selectedIds.isEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: Icon(Icons.close_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
        title: _selectedIds.isEmpty
            ? Text('المواعيد',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3)
            : Text('تم تحديد ${_selectedIds.length}',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        actions: _selectedIds.isEmpty
            ? null
            : [
                appointmentsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (appointments) {
                    var filtered = appointments.toList();
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((a) {
                        return a.title.toLowerCase().contains(q) ||
                            (a.location ?? '').toLowerCase().contains(q) ||
                            a.date.contains(q) ||
                            a.time.contains(q);
                      }).toList();
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _selectedIds.length == filtered.length
                                ? Icons.deselect_rounded
                                : Icons.select_all_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedIds.length == filtered.length) {
                                _selectedIds.clear();
                              } else {
                                _selectedIds.addAll(filtered.map((a) => a.id));
                              }
                            });
                          },
                        ),
                        ExportButton(
                          itemCount: _selectedIds.length,
                          onExport: (format) {
                            final selectedItems = filtered
                                .where((a) => _selectedIds.contains(a.id))
                                .toList();
                            selectedItems.sort((a, b) => '${a.date} ${a.time}'.compareTo('${b.date} ${b.time}'));
                            final exportService = ref.read(exportServiceProvider);
                            exportService.exportDataList(
                              context: context,
                              title: 'مواعيد الإدارة التنفيذية المحددة',
                              items: selectedItems,
                              headers: [
                                'م',
                                'الموعد / العنوان',
                                'التاريخ',
                                'الوقت',
                                'المدة (دقائق)',
                                'الموقع / المكان',
                                'الحالة'
                              ],
                              itemMapper: (items) => items.asMap().entries.map((entry) {
                                final i = entry.key + 1;
                                final a = entry.value;
                                String statusStr = 'جديد';
                                if (a.status == 1) statusStr = 'قيد التنفيذ';
                                if (a.status == 2) statusStr = 'بانتظار الرد';
                                if (a.status == 3) statusStr = 'مكتمل';
                                if (a.status == 4) statusStr = 'متأخر';
                                if (a.status == 5) statusStr = 'متعثر';
                                if (a.status == 6) statusStr = 'ملغي';
                                return [
                                  i.toString(),
                                  a.title,
                                  a.date,
                                  a.time,
                                  a.durationMinutes.toString(),
                                  a.location ?? 'غير محدد',
                                  statusStr,
                                ];
                              }).toList(),
                              format: format,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: NeuColors.priorityCritical,
                          ),
                          onPressed: () => _confirmDeleteSelected(context),
                        ),
                      ],
                    );
                  },
                ),
              ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search
            SearchFilterBar(
              searchHint: 'بحث في المواعيد...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,

            // List
            Expanded(
              child: appointmentsAsync.when(
                data: (appointments) {
                  var filtered = appointments.toList();

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((a) {
                      return a.title
                              .toLowerCase()
                              .contains(q) ||
                          (a.location ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          a.date.contains(q) ||
                          a.time.contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد مواعيد مجدولة',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      final isSelected = _selectedIds.contains(appointment.id);

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 16),
                        child: NeuCard(
                          onTap: () {
                            if (_selectedIds.isNotEmpty) {
                              _toggleSelection(appointment.id);
                            } else {
                              // original had no navigate, so just toggle or detail if supported
                              _toggleSelection(appointment.id);
                            }
                          },
                          onLongPress: () => _toggleSelection(appointment.id),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              if (_selectedIds.isNotEmpty) ...[
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? (isDark
                                          ? NeuColors.goldAccent
                                          : NeuColors.navyDeep)
                                      : (isDark
                                          ? NeuColors.textHintDark
                                          : NeuColors.textHint),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                              ],
                              
                              // Time Indicator
                              Container(
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? NeuColors.navyLight
                                          : NeuColors.navyMid)
                                      .withAlpha(25),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      appointment.time,
                                      style: (isDark
                                              ? AppTypography
                                                  .h3Dark
                                              : AppTypography.h3)
                                          .copyWith(
                                              fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${appointment.durationMinutes} دقيقة',
                                      style: isDark
                                          ? AppTypography
                                              .captionDark
                                          : AppTypography
                                              .caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.title,
                                      style: (isDark
                                              ? AppTypography
                                                  .h3Dark
                                              : AppTypography.h3)
                                          .copyWith(
                                              fontSize: 18),
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .calendar_today_rounded,
                                            size: 14,
                                            color: isDark
                                                ? NeuColors
                                                    .textHintDark
                                                : NeuColors
                                                    .textHint),
                                        const SizedBox(
                                            width: 4),
                                        Text(
                                            appointment.date,
                                            style: isDark
                                                ? AppTypography
                                                    .captionDark
                                                : AppTypography
                                                    .caption),
                                        if (appointment
                                                    .location !=
                                                null &&
                                            appointment
                                                .location!
                                                .isNotEmpty) ...[
                                          const SizedBox(
                                              width: 12),
                                          Icon(
                                              Icons
                                                  .location_on_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? NeuColors
                                                      .textHintDark
                                                  : NeuColors
                                                      .textHint),
                                          const SizedBox(
                                              width: 4),
                                          Expanded(
                                            child: Text(
                                                appointment
                                                    .location!,
                                                style: isDark
                                                    ? AppTypography
                                                        .captionDark
                                                    : AppTypography
                                                        .caption,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (error, _) => Center(
                    child: Text(
                        'خطأ في جلب المواعيد: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              onPressed: () =>
                  context.push(RouteNames.appointmentCreate),
              backgroundColor: NeuColors.navyDeep,
              child: const Icon(Icons.add_rounded,
                  color: Colors.white),
            )
          : null,
    );
  }

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: NeuCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: NeuColors.priorityCritical,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تأكيد الحذف',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(
                      color: NeuColors.priorityCritical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف المواعيد المحددة (${_selectedIds.length})؟ لا يمكن التراجع عن هذا الإجراء.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: NeuButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _deleteSelectedItems();
                          },
                          label: 'حذف',
                          variant: NeuButtonVariant.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          label: 'إلغاء',
                          variant: NeuButtonVariant.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteSelectedItems() async {
    try {
      final repo = ref.read(appointmentsRepositoryProvider);
      for (final id in _selectedIds) {
        await repo.deleteAppointment(id);
      }
      setState(() {
        _selectedIds.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المواعيد المحددة بنجاح', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحذف: $e', textDirection: TextDirection.rtl),
            backgroundColor: NeuColors.priorityCritical,
          ),
        );
      }
    }
  }
}
