import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/follow_ups_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

/// Create Follow-up Screen
class CreateFollowupScreen extends ConsumerStatefulWidget {
  const CreateFollowupScreen({super.key});

  @override
  ConsumerState<CreateFollowupScreen> createState() => _CreateFollowupScreenState();
}

class _CreateFollowupScreenState extends ConsumerState<CreateFollowupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _assignedToController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  FollowUpEntityType _selectedType = FollowUpEntityType.meeting;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(followUpsRepositoryProvider);
      
      await repository.createFollowUp(
        title: _titleController.text,
        type: _selectedType,
        priority: _selectedPriority,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        targetDate: _selectedDate.toIso8601String().split('T').first,
        assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المتابعة بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('إضافة متابعة جديدة', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              NeuInput(
                controller: _titleController,
                label: 'موضوع المتابعة',
                hint: 'أدخل موضوع المتابعة',
                prefixIcon: Icons.replay_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapLg,

              Text('النوع', style: AppTypography.label),
              AppSpacing.gapSm,
              Wrap(
                spacing: 8, runSpacing: 8,
                children: FollowUpEntityType.values.map((t) => GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedType == t ? NeuColors.navyDeep : NeuColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(t.arabicLabel, style: AppTypography.bodySmall.copyWith(color: _selectedType == t ? NeuColors.textOnDark : NeuColors.textSecondary)),
                  ),
                )).toList(),
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _notesController,
                label: 'ملاحظات',
                hint: 'تفاصيل إضافية',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _assignedToController,
                label: 'جهة المتابعة',
                hint: 'الشخص أو الجهة المسؤولة',
                prefixIcon: Icons.business_rounded,
              ),
              AppSpacing.gapLg,

              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: NeuCard(
                      margin: EdgeInsets.zero, radius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: NeuColors.navyMid),
                        AppSpacing.gapHSm,
                        Text(DateFormat('d MMM yyyy', 'ar').format(_selectedDate), style: AppTypography.body),
                      ]),
                    ),
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              Text('الأولوية', style: AppTypography.label),
              AppSpacing.gapSm,
              Row(children: Priority.values.map((p) {
                final colors = {
                  Priority.critical: NeuColors.priorityCritical,
                  Priority.high: NeuColors.priorityHigh,
                  Priority.medium: NeuColors.priorityMedium,
                  Priority.low: NeuColors.priorityLow,
                };
                final c = colors[p]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedPriority == p ? c.withValues(alpha: 0.15) : NeuColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedPriority == p ? c : Colors.transparent, width: 1.5),
                      ),
                      child: Text(p.arabicLabel, style: AppTypography.caption.copyWith(color: _selectedPriority == p ? c : NeuColors.textHint, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    ),
                  ),
                );
              }).toList()),
              AppSpacing.gapXxl,

              NeuButton(label: 'حفظ المتابعة', onPressed: _isSubmitting ? null : _submit, isLoading: _isSubmitting, icon: Icons.check_rounded),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
