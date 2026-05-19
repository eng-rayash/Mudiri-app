import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../domain/movements_repository.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';

/// Create Movement Screen — تحرك
///
/// Allows the executive to log an outbound movement/dispatch.
class CreateMovementScreen extends ConsumerStatefulWidget {
  const CreateMovementScreen({super.key});

  @override
  ConsumerState<CreateMovementScreen> createState() =>
      _CreateMovementScreenState();
}

class _CreateMovementScreenState
    extends ConsumerState<CreateMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _movementType = 0; // 0: خروج, 1: عودة, 2: مهمة خارجية

  bool _isSaving = false;

  static const List<String> _types = ['خروج', 'عودة', 'مهمة خارجية'];

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(movementsRepositoryProvider);
      
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await repository.createMovement(
        destination: _destinationCtrl.text,
        purpose: _purposeCtrl.text.isNotEmpty ? _purposeCtrl.text : null,
        date: dateStr,
        time: timeStr,
        type: _movementType,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل التحرك بنجاح'),
            backgroundColor: NeuColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: NeuColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        DateFormat('dd/MM/yyyy', 'ar').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تسجيل تحرك',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              AppSpacing.gapMd,

              // Movement Type Selector
              Text(
                'نوع التحرك',
                style: isDark ? AppTypography.labelDark : AppTypography.label,
              ),
              AppSpacing.gapSm,
              NeuCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: Row(
                  children: List.generate(_types.length, (i) {
                    final selected = _movementType == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _movementType = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? NeuColors.navyDeep
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _types[i],
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: selected
                                  ? NeuColors.textOnDark
                                  : (isDark
                                      ? NeuColors.textSecondaryDark
                                      : NeuColors.textSecondary),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              AppSpacing.gapLg,

              // Destination
              _buildLabel('الوجهة / المكان', isDark),
              AppSpacing.gapSm,
              _buildTextField(
                controller: _destinationCtrl,
                hint: 'أدخل المكان أو الوجهة',
                icon: Icons.location_on_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الوجهة مطلوبة' : null,
                isDark: isDark,
              ),

              AppSpacing.gapLg,

              // Purpose
              _buildLabel('الغرض / المهمة', isDark),
              AppSpacing.gapSm,
              _buildTextField(
                controller: _purposeCtrl,
                hint: 'اكتب الغرض من التحرك',
                icon: Icons.article_rounded,
                maxLines: 2,
                isDark: isDark,
              ),

              AppSpacing.gapLg,

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('التاريخ', isDark),
                        AppSpacing.gapSm,
                        GestureDetector(
                          onTap: _pickDate,
                          child: NeuCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: NeuColors.goldAccent,
                                ),
                                AppSpacing.gapHSm,
                                Text(
                                  dateStr,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('الوقت', isDark),
                        AppSpacing.gapSm,
                        GestureDetector(
                          onTap: _pickTime,
                          child: NeuCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: NeuColors.goldAccent,
                                ),
                                AppSpacing.gapHSm,
                                Text(
                                  timeStr,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.gapLg,

              // Notes
              _buildLabel('ملاحظات إضافية', isDark),
              AppSpacing.gapSm,
              _buildTextField(
                controller: _notesCtrl,
                hint: 'أي ملاحظات تتعلق بالتحرك...',
                icon: Icons.notes_rounded,
                maxLines: 3,
                isDark: isDark,
              ),

              AppSpacing.gapXxl,

              // Save Button
              NeuButton(
                label: _isSaving ? 'جارٍ الحفظ...' : 'حفظ التحرك',
                icon: _isSaving
                    ? null
                    : Icons.save_rounded,
                onPressed: _isSaving ? null : _save,
              ),

              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(
        text,
        style: isDark ? AppTypography.labelDark : AppTypography.label,
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: isDark ? AppTypography.bodyDark : AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: isDark
            ? AppTypography.captionDark
            : AppTypography.caption,
        prefixIcon: Icon(
          icon,
          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: NeuColors.goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: NeuColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: NeuColors.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}
