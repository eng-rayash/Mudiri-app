import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_button.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../../../shared/widgets/neu_input.dart';
import '../../domain/directives_repository.dart';

/// Create Directive Page — form for issuing a new executive directive.
class CreateDirectivePage extends ConsumerStatefulWidget {
  const CreateDirectivePage({super.key});

  @override
  ConsumerState<CreateDirectivePage> createState() =>
      _CreateDirectivePageState();
}

class _CreateDirectivePageState
    extends ConsumerState<CreateDirectivePage> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _assignedCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Priority _priority = Priority.medium;
  DateTime? _deadline;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    _sourceCtrl.dispose();
    _assignedCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(directivesRepositoryProvider).createDirective(
            title: _titleCtrl.text.trim(),
            details: _detailsCtrl.text.trim().isEmpty
                ? null
                : _detailsCtrl.text.trim(),
            source: _sourceCtrl.text.trim().isEmpty
                ? null
                : _sourceCtrl.text.trim(),
            assignedTo: _assignedCtrl.text.trim().isEmpty
                ? null
                : _assignedCtrl.text.trim(),
            priority: _priority,
            deadline: _deadline != null
                ? DateFormat('yyyy-MM-dd').format(_deadline!)
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white),
                SizedBox(width: 12),
                Text('تم إصدار التوجيه بنجاح'),
              ],
            ),
            backgroundColor: NeuColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: NeuColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'إصدار توجيه جديد',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeuInput(
                  controller: _titleCtrl,
                  label: 'عنوان التوجيه',
                  hint: 'أدخل عنوان التوجيه',
                  prefixIcon: Icons.assignment_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'العنوان مطلوب'
                      : null,
                ),

                AppSpacing.gapLg,

                NeuInput(
                  controller: _detailsCtrl,
                  label: 'تفاصيل التوجيه',
                  hint: 'أدخل التفاصيل والتعليمات',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 4,
                  minLines: 3,
                ),

                AppSpacing.gapLg,

                NeuInput(
                  controller: _sourceCtrl,
                  label: 'مصدر التوجيه',
                  hint: 'مثل: المدير العام، مجلس الإدارة',
                  prefixIcon: Icons.badge_rounded,
                ),

                AppSpacing.gapLg,

                NeuInput(
                  controller: _assignedCtrl,
                  label: 'الجهة المنفذة',
                  hint: 'القسم أو الشخص المسؤول',
                  prefixIcon: Icons.people_rounded,
                ),

                AppSpacing.gapLg,

                // Priority picker
                Text(
                  'الأولوية',
                  style: isDark
                      ? AppTypography.labelDark
                      : AppTypography.label,
                ),
                AppSpacing.gapSm,
                Wrap(
                  spacing: 8,
                  children: Priority.values.map((p) {
                    final isSelected = p == _priority;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _priorityColor(p)
                                  .withValues(alpha: 0.15)
                              : (isDark
                                  ? NeuColors.surfaceDark
                                  : NeuColors.surface),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? _priorityColor(p)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          p.arabicLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? _priorityColor(p)
                                : (isDark
                                    ? NeuColors
                                        .textSecondaryDark
                                    : NeuColors
                                        .textSecondary),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                AppSpacing.gapLg,

                // Deadline
                Text(
                  'موعد التنفيذ',
                  style: isDark
                      ? AppTypography.labelDark
                      : AppTypography.label,
                ),
                AppSpacing.gapSm,
                NeuCard(
                  onTap: _pickDeadline,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: isDark
                            ? NeuColors.goldAccent
                            : NeuColors.navyDeep,
                        size: 20,
                      ),
                      AppSpacing.gapHSm,
                      Text(
                        _deadline != null
                            ? DateFormat('yyyy/MM/dd')
                                .format(_deadline!)
                            : 'اختر التاريخ',
                        style: isDark
                            ? AppTypography.bodyDark
                            : AppTypography.body,
                      ),
                    ],
                  ),
                ),

                AppSpacing.gapXxl,

                // Submit
                NeuButton(
                  label: 'إصدار التوجيه',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  icon: Icons.send_rounded,
                ),

                AppSpacing.gapXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.critical:
        return NeuColors.priorityCritical;
      case Priority.high:
        return NeuColors.priorityHigh;
      case Priority.medium:
        return NeuColors.priorityMedium;
      case Priority.low:
        return NeuColors.priorityLow;
    }
  }
}
