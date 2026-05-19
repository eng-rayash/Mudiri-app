import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/calls_repository.dart';

/// Calls List Screen — Phase 4
class CallsListScreen extends ConsumerWidget {
  const CallsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsState = ref.watch(callsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('سجل المكالمات', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_ic_call_rounded, color: NeuColors.navyDeep),
            onPressed: () => _showAddCallModal(context, ref),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: callsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
        data: (calls) {
          if (calls.isEmpty) {
            return const Center(child: Text('لا توجد مكالمات مسجلة', style: AppTypography.body));
          }

          return ListView.separated(
            padding: AppSpacing.screen,
            itemCount: calls.length,
            separatorBuilder: (context, index) => AppSpacing.gapMd,
            itemBuilder: (context, index) {
              final call = calls[index];
              return NeuCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildCallIcon(call.callType),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(call.callerName, style: AppTypography.h4),
                              if (call.isImportant) ...[
                                AppSpacing.gapHSm,
                                const Icon(Icons.star_rounded, color: NeuColors.goldAccent, size: 16),
                              ]
                            ],
                          ),
                          AppSpacing.gapXs,
                          Text('${call.date} - ${call.time}', style: AppTypography.caption),
                          if (call.summary != null && call.summary!.isNotEmpty) ...[
                            AppSpacing.gapXs,
                            Text(call.summary!, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ]
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
    );
  }

  Widget _buildCallIcon(int type) {
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
        color: NeuColors.bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: NeuColors.shadowDark, offset: const Offset(3, 3), blurRadius: 6),
          BoxShadow(color: NeuColors.shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _showAddCallModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    int selectedType = 0;
    bool isImportant = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: NeuColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تسجيل مكالمة جديدة', style: AppTypography.h3),
                AppSpacing.gapLg,
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المتصل', border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                TextField(
                  controller: summaryCtrl,
                  decoration: const InputDecoration(labelText: 'ملخص المكالمة', border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                DropdownButtonFormField<int>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('مكالمة واردة')),
                    DropdownMenuItem(value: 1, child: Text('مكالمة صادرة')),
                    DropdownMenuItem(value: 2, child: Text('مكالمة فائتة')),
                  ],
                  onChanged: (val) => setState(() => selectedType = val ?? 0),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                AppSpacing.gapMd,
                SwitchListTile(
                  title: const Text('مكالمة هامة', style: AppTypography.body),
                  value: isImportant,
                  onChanged: (val) => setState(() => isImportant = val),
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
                      ref.read(callsRepositoryProvider).logCall(
                            callerName: nameCtrl.text,
                            callType: selectedType,
                            date: '${now.year}-${now.month}-${now.day}',
                            time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
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
