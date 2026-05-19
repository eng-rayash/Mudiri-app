import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/visitors_repository.dart';

/// Visitors List Screen — Phase 4
class VisitorsListScreen extends ConsumerWidget {
  const VisitorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorsState = ref.watch(activeVisitorsProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('لوحة الزوار', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
        children: [
          Padding(
            padding: AppSpacing.screen,
            child: Row(
              children: [
                Expanded(
                  child: NeuButton(
                    label: 'تسجيل زائر',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => _showAddVisitorDialog(context, ref),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: visitorsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ: $err')),
              data: (visitors) {
                if (visitors.isEmpty) {
                  return const Center(child: Text('لا يوجد زوار في الانتظار أو بالداخل', style: AppTypography.body));
                }

                return ListView.separated(
                  padding: AppSpacing.screenH,
                  itemCount: visitors.length,
                  separatorBuilder: (context, index) => AppSpacing.gapMd,
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return NeuCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: NeuColors.navyMid,
                          child: Text(visitor.visitorName[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(visitor.visitorName, style: AppTypography.h4),
                        subtitle: Text(
                          'الجهة: ${visitor.company ?? 'غير محدد'} • وقت الدخول: ${visitor.entryTime}',
                          style: AppTypography.caption,
                        ),
                        trailing: visitor.status == 1
                            ? TextButton.icon(
                                icon: const Icon(Icons.exit_to_app_rounded, color: NeuColors.danger),
                                label: const Text('تسجيل خروج', style: TextStyle(color: NeuColors.danger)),
                                onPressed: () {
                                  ref.read(visitorsRepositoryProvider).checkoutVisitor(visitor.id, visitor.visitorName);
                                },
                              )
                            : const Text('بالانتظار', style: TextStyle(color: NeuColors.warning)),
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

  void _showAddVisitorDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeuColors.bgColor,
        title: const Text('دخول زائر جديد', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الزائر')),
            AppSpacing.gapSm,
            TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'الجهة / الشركة')),
            AppSpacing.gapSm,
            TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'سبب الزيارة')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          NeuButton(
            label: 'تسجيل الدخول',
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(visitorsRepositoryProvider).registerVisitor(
                      visitorName: nameCtrl.text,
                      company: companyCtrl.text,
                      purpose: purposeCtrl.text,
                    );
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
