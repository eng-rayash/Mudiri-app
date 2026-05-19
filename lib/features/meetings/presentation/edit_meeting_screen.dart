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
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

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

  MeetingType? _selectedType;
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _objectiveController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initData(dynamic meeting) {
    if (_isInitialized) return;
    
    _titleController.text = meeting.title;
    _locationController.text = meeting.location ?? '';
    _objectiveController.text = meeting.objective ?? '';
    _notesController.text = meeting.notes ?? '';

    _selectedType = MeetingType.fromValue(meeting.meetingType);
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
    if (!_formKey.currentState!.validate() || _selectedType == null || _selectedPriority == null || _selectedDate == null || _selectedTime == null) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(meetingsRepositoryProvider);
      final formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      await repository.updateMeetingDetails(
        id: widget.meetingId,
        title: _titleController.text,
        type: _selectedType!,
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

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('تعديل الاجتماع', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: meetingState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (meeting) {
            if (meeting == null) return const Center(child: Text('الاجتماع غير موجود'));
            
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
                  Text('نوع الاجتماع', style: AppTypography.label),
                  AppSpacing.gapSm,
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: MeetingType.values.map((t) => GestureDetector(
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

                  // Date & Time Row
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
                            Text(_selectedDate != null ? DateFormat('d MMM yyyy', 'ar').format(_selectedDate!) : '...', style: AppTypography.body),
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
                            const Icon(Icons.access_time_rounded, size: 18, color: NeuColors.navyMid),
                            AppSpacing.gapHSm,
                            Text(_selectedTime != null ? _selectedTime!.format(context) : '...', style: AppTypography.body),
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
