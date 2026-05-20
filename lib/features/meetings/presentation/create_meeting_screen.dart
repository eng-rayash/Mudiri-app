import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/meetings_repository.dart';
import '../providers/meeting_categories_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

/// Create Meeting Screen — full meeting form with attendees, agenda & decisions.
///
/// Fields:
/// - عنوان الاجتماع (title)
/// - نوع الاجتماع (type)
/// - التاريخ والوقت (date & time)
/// - المكان (location)
/// - هدف الاجتماع (objective)
/// - الأولوية (priority)
/// - قائمة الحضور (attendees — dynamic list)
/// - جدول الأعمال (agenda — dynamic list)
/// - القرارات (decisions — dynamic list)
/// - ملاحظات (notes)
class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() =>
      _CreateMeetingScreenState();
}

class _CreateMeetingScreenState
    extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Text Controllers ──────────────────────────────────────────
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _notesController = TextEditingController();
  final _typeController = TextEditingController();

  // ─── Dynamic Lists ─────────────────────────────────────────────
  final List<String> _attendees = [];
  final List<String> _agendaItems = [];
  final List<String> _decisions = [];

  // ─── State ─────────────────────────────────────────────────────
  Priority _selectedPriority = Priority.medium;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _objectiveController.dispose();
    _notesController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  // ─── Pickers ───────────────────────────────────────────────────

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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─── Dynamic List Dialogs ──────────────────────────────────────

  void _addItemDialog({
    required String title,
    required String hint,
    required List<String> targetList,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? NeuColors.bgColorDark
              : NeuColors.bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(title,
              style: Theme.of(context).brightness == Brightness.dark
                  ? AppTypography.h4Dark
                  : AppTypography.h4),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).brightness == Brightness.dark
                ? AppTypography.bodyDark
                : AppTypography.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.caption,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? NeuColors.surfaceDark
                  : NeuColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: NeuColors.goldAccent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: AppTypography.bodySmall
                      .copyWith(color: NeuColors.textSecondary)),
            ),
            NeuButton(
              label: 'إضافة',
              icon: Icons.add_rounded,
              isExpanded: false,
              radius: 12,
              onPressed: () {
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  setState(() => targetList.add(text));
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Submit ────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime.minute.toString().padLeft(2, '0')}';

      final typeStr = _typeController.text.trim();
      MeetingType finalEnum;
      try {
        finalEnum = MeetingType.values.firstWhere((e) => e.arabicLabel == typeStr);
      } catch (_) {
        finalEnum = MeetingType.general;
      }
      
      String? customMeetingType = finalEnum == MeetingType.general && typeStr != MeetingType.general.arabicLabel 
          ? typeStr 
          : null;

      await ref.read(meetingCategoriesProvider.notifier).addCategory(typeStr);

      await ref.read(meetingsRepositoryProvider).createMeeting(
            title: _titleController.text.trim(),
            type: finalEnum,
            customMeetingType: customMeetingType,
            date: _selectedDate,
        time: formattedTime,
        priority: _selectedPriority,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        objective: _objectiveController.text.isNotEmpty
            ? _objectiveController.text
            : null,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
        attendees: _attendees.isNotEmpty
            ? jsonEncode(_attendees)
            : null,
        agenda: _agendaItems.isNotEmpty
            ? jsonEncode(_agendaItems)
            : null,
        decisions: _decisions.isNotEmpty
            ? jsonEncode(_decisions)
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الاجتماع بنجاح'),
            backgroundColor: NeuColors.success,
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────

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
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
          onPressed: () => context.pop(),
        ),
        title: Text('اجتماع جديد',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // ── Title ──────────────────────────────────────────
              NeuInput(
                controller: _titleController,
                label: 'عنوان الاجتماع',
                hint: 'أدخل عنوان الاجتماع',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapLg,

              // ── Meeting Type ───────────────────────────────────
              NeuInput(
                controller: _typeController,
                label: 'نوع الاجتماع *',
                hint: 'اكتب نوع الاجتماع (مثال: إداري، طارئ...)',
                prefixIcon: Icons.group_work_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى تحديد أو كتابة نوع الاجتماع' : null,
              ),
              AppSpacing.gapSm,
              Text(
                'اختر من القائمة أو أضف نوعاً جديداً. اضغط مطولاً على أي نوع لحذفه.',
                style: isDark ? AppTypography.captionDark : AppTypography.caption,
              ),
              AppSpacing.gapSm,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (ref.watch(meetingCategoriesProvider).value ?? []).map((type) {
                  final isSelected = _typeController.text.trim() == type;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _typeController.text = type;
                      });
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('حذف نوع الاجتماع', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
                          content: Text('هل تريد إزالة "$type" من قائمة الاقتراحات المحفوظة؟', style: isDark ? AppTypography.bodyDark : AppTypography.body),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('إلغاء', style: TextStyle(color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('حذف', style: TextStyle(color: NeuColors.priorityCritical, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(meetingCategoriesProvider.notifier).removeCategory(type);
                      }
                    },
                    child: AnimatedContainer(
                      duration: NeuDecorations.pressDuration,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: isSelected
                          ? NeuDecorations.neuPressed(radius: 12, isDark: isDark)
                          : NeuDecorations.neuFlat(radius: 12, isDark: isDark),
                      child: Text(
                        type,
                        style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                          color: isSelected 
                              ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                              : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapLg,

              // ── Date & Time ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: 16,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18,
                                color: isDark
                                    ? NeuColors.goldAccent
                                    : NeuColors.navyMid),
                            AppSpacing.gapHSm,
                            Text(
                              DateFormat('d MMM yyyy', 'ar')
                                  .format(_selectedDate),
                              style: isDark
                                  ? AppTypography.bodyDark
                                  : AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: 16,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 18,
                                color: isDark
                                    ? NeuColors.goldAccent
                                    : NeuColors.navyMid),
                            AppSpacing.gapHSm,
                            Text(
                              _selectedTime.format(context),
                              style: isDark
                                  ? AppTypography.bodyDark
                                  : AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,

              // ── Location ───────────────────────────────────────
              NeuInput(
                controller: _locationController,
                label: 'المكان',
                hint: 'مكان الاجتماع',
                prefixIcon: Icons.location_on_outlined,
              ),
              AppSpacing.gapLg,

              // ── Objective ──────────────────────────────────────
              NeuInput(
                controller: _objectiveController,
                label: 'هدف الاجتماع',
                hint: 'اكتب هدف الاجتماع',
                maxLines: 3,
                prefixIcon: Icons.flag_outlined,
              ),
              AppSpacing.gapLg,

              // ── Priority ──────────────────────────────────────
              Text('الأولوية',
                  style: isDark
                      ? AppTypography.labelDark
                      : AppTypography.label),
              AppSpacing.gapSm,
              Row(
                children: Priority.values.map((p) {
                  final colors = {
                    Priority.critical: NeuColors.priorityCritical,
                    Priority.high: NeuColors.priorityHigh,
                    Priority.medium: NeuColors.priorityMedium,
                    Priority.low: NeuColors.priorityLow,
                  };
                  final c = colors[p]!;
                  final selected = _selectedPriority == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin:
                            const EdgeInsetsDirectional.only(end: 8),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.withAlpha(38)
                              : (isDark
                                  ? NeuColors.surfaceDark
                                  : NeuColors.surface),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                selected ? c : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          p.arabicLabel,
                          style: AppTypography.caption.copyWith(
                            color: selected
                                ? c
                                : (isDark
                                    ? NeuColors.textHintDark
                                    : NeuColors.textHint),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapXxl,

              // ══════════════════════════════════════════════════
              // قائمة الحضور — Attendees
              // ══════════════════════════════════════════════════
              _buildDynamicListSection(
                icon: Icons.groups_rounded,
                title: 'قائمة الحضور',
                items: _attendees,
                emptyHint: 'لم يتم إضافة حضور بعد',
                addLabel: 'إضافة حاضر',
                dialogTitle: 'إضافة حاضر جديد',
                dialogHint: 'اسم الحاضر أو منصبه',
                isDark: isDark,
              ),
              AppSpacing.gapXxl,

              // ══════════════════════════════════════════════════
              // جدول الأعمال — Agenda
              // ══════════════════════════════════════════════════
              _buildDynamicListSection(
                icon: Icons.list_alt_rounded,
                title: 'جدول الأعمال',
                items: _agendaItems,
                emptyHint: 'لم يتم إضافة بنود بعد',
                addLabel: 'إضافة بند',
                dialogTitle: 'إضافة بند جديد',
                dialogHint: 'وصف البند',
                isDark: isDark,
                isNumbered: true,
              ),
              AppSpacing.gapXxl,

              // ══════════════════════════════════════════════════
              // القرارات — Decisions
              // ══════════════════════════════════════════════════
              _buildDynamicListSection(
                icon: Icons.gavel_rounded,
                title: 'القرارات',
                items: _decisions,
                emptyHint: 'لم يتم تسجيل قرارات بعد',
                addLabel: 'إضافة قرار',
                dialogTitle: 'تسجيل قرار جديد',
                dialogHint: 'نص القرار',
                isDark: isDark,
                isNumbered: true,
                accentColor: NeuColors.goldAccent,
              ),
              AppSpacing.gapXxl,

              // ── Notes ──────────────────────────────────────────
              NeuInput(
                controller: _notesController,
                label: 'ملاحظات',
                hint: 'ملاحظات إضافية',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapXxl,

              // ── Submit ─────────────────────────────────────────
              NeuButton(
                label: 'إنشاء الاجتماع',
                onPressed: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
                icon: Icons.check_rounded,
              ),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dynamic List Section Builder ──────────────────────────────

  Widget _buildDynamicListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required String emptyHint,
    required String addLabel,
    required String dialogTitle,
    required String dialogHint,
    required bool isDark,
    bool isNumbered = false,
    Color? accentColor,
  }) {
    final color = accentColor ??
        (isDark ? NeuColors.goldAccent : NeuColors.navyDeep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 25 : 15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            AppSpacing.gapHSm,
            Text(
              title,
              style: isDark
                  ? AppTypography.h4Dark
                  : AppTypography.h4,
            ),
            const Spacer(),
            // Item count badge
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.gapSm,

        // Items List or Empty State
        if (items.isEmpty)
          NeuCard(
            padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: isDark
                        ? NeuColors.textHintDark
                        : NeuColors.textHint),
                AppSpacing.gapHSm,
                Text(
                  emptyHint,
                  style: isDark
                      ? AppTypography.captionDark
                      : AppTypography.caption,
                ),
              ],
            ),
          )
        else
          NeuCard(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 12),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      // Number or bullet
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withAlpha(isDark ? 20 : 12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isNumbered
                              ? Text(
                                  '${i + 1}',
                                  style:
                                      AppTypography.caption.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Icon(Icons.person_rounded,
                                  size: 14, color: color),
                        ),
                      ),
                      AppSpacing.gapHSm,
                      Expanded(
                        child: Text(
                          item,
                          style: isDark
                              ? AppTypography.bodyDark
                              : AppTypography.body,
                        ),
                      ),
                      // Delete button
                      GestureDetector(
                        onTap: () => setState(
                            () => items.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: NeuColors.danger.withAlpha(12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: NeuColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        AppSpacing.gapSm,

        // Add Button
        GestureDetector(
          onTap: () => _addItemDialog(
            title: dialogTitle,
            hint: dialogHint,
            targetList: items,
          ),
          child: NeuCard(
            margin: EdgeInsets.zero,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            radius: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    size: 18, color: color),
                AppSpacing.gapHSm,
                Text(
                  addLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
