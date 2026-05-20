import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/meetings_repository.dart';
import '../providers/meetings_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../providers/meeting_categories_provider.dart';

/// Edit Meeting Screen — form for editing an existing meeting.
class EditMeetingScreen extends ConsumerStatefulWidget {
  const EditMeetingScreen({super.key, required this.meetingId});

  final int meetingId;

  @override
  ConsumerState<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends ConsumerState<EditMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _objectiveController;
  late TextEditingController _notesController;
  late TextEditingController _typeController;

  Priority? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _objectiveController = TextEditingController();
    _notesController = TextEditingController();
    _typeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _objectiveController.dispose();
    _notesController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _initData(dynamic meeting) {
    if (_isInitialized) return;
    
    _titleController.text = meeting.title;
    _locationController.text = meeting.location ?? '';
    _objectiveController.text = meeting.objective ?? '';
    _notesController.text = meeting.notes ?? '';

    _typeController.text = meeting.customMeetingType ?? MeetingType.fromValue(meeting.meetingType).arabicLabel;
    _selectedPriority = Priority.fromValue(meeting.priority);
    _selectedDate = DateTime.parse(meeting.date);
    
    final parts = meeting.time.split(':');
    if (parts.length >= 2) {
      _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      _selectedTime = TimeOfDay.now();
    }
    
    _isInitialized = true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _typeController.text.trim().isEmpty || _selectedPriority == null || _selectedDate == null || _selectedTime == null) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(meetingsRepositoryProvider);
      final formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
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

      await repository.updateMeetingDetails(
        id: widget.meetingId,
        title: _titleController.text.trim(),
        type: finalEnum,
        customMeetingType: customMeetingType,
        date: _selectedDate!,
        time: formattedTime,
        priority: _selectedPriority!,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        objective: _objectiveController.text.isNotEmpty ? _objectiveController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
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
    final meetingState = ref.watch(meetingDetailProvider(widget.meetingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'تعديل الاجتماع', 
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: meetingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err', style: isDark ? AppTypography.bodyDark : AppTypography.body)),
          data: (meeting) {
            if (meeting == null) return Center(child: Text('الاجتماع غير موجود', style: isDark ? AppTypography.bodyDark : AppTypography.body));
            
            // Initialize data once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _initData(meeting);
              });
            });

            if (!_isInitialized) return const Center(child: CircularProgressIndicator());

            return Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.screen,
                children: [
                  // Title
                  NeuInput(
                    controller: _titleController,
                    label: 'عنوان الاجتماع',
                    hint: 'أدخل عنوان الاجتماع',
                    prefixIcon: Icons.title_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  AppSpacing.gapLg,

                  // Meeting Type
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
                    spacing: 10, runSpacing: 10,
                    children: (ref.watch(meetingCategoriesProvider).value ?? []).map((type) {
                      final isSelected = _typeController.text.trim() == type;
                      return GestureDetector(
                        onTap: () => setState(() => _typeController.text = type),
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

                  // Date & Time Row
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: NeuCard(
                          margin: EdgeInsets.zero, radius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Icon(
                              Icons.calendar_today_rounded, 
                              size: 18, 
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                            ),
                            AppSpacing.gapHSm,
                            Text(
                              _selectedDate != null ? DateFormat('d MMM yyyy', 'ar').format(_selectedDate!) : '...', 
                              style: isDark ? AppTypography.bodyDark : AppTypography.body,
                            ),
                          ]),
                        ),
                      ),
                    ),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: NeuCard(
                          margin: EdgeInsets.zero, radius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Icon(
                              Icons.access_time_rounded, 
                              size: 18, 
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                            ),
                            AppSpacing.gapHSm,
                            Text(
                              _selectedTime != null ? _selectedTime!.format(context) : '...', 
                              style: isDark ? AppTypography.bodyDark : AppTypography.body,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                  AppSpacing.gapLg,

                  // Location
                  NeuInput(controller: _locationController, label: 'المكان', hint: 'مكان الاجتماع', prefixIcon: Icons.location_on_outlined),
                  AppSpacing.gapLg,

                  // Objective
                  NeuInput(controller: _objectiveController, label: 'هدف الاجتماع', hint: 'اكتب هدف الاجتماع', maxLines: 3, prefixIcon: Icons.flag_outlined),
                  AppSpacing.gapLg,

                  // Priority
                  Text(
                    'الأولوية', 
                    style: isDark ? AppTypography.labelDark : AppTypography.label,
                  ),
                  AppSpacing.gapSm,
                  Row(children: Priority.values.map((p) {
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
                        onTap: () => setState(() => _selectedPriority = p),
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected 
                                ? c.withValues(alpha: 0.15) 
                                : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? c : Colors.transparent, 
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            p.arabicLabel, 
                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                              color: selected 
                                  ? c 
                                  : (isDark ? NeuColors.textHintDark : NeuColors.textHint), 
                              fontWeight: FontWeight.w600,
                            ), 
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                  AppSpacing.gapLg,

                  // Notes
                  NeuInput(controller: _notesController, label: 'ملاحظات', hint: 'ملاحظات إضافية', maxLines: 3, prefixIcon: Icons.notes_rounded),
                  AppSpacing.gapXxl,

                  // Submit Button
                  NeuButton(label: 'حفظ التعديلات', onPressed: _isSubmitting ? null : _submit, isLoading: _isSubmitting, icon: Icons.save_rounded),
                  AppSpacing.gapXxl,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
