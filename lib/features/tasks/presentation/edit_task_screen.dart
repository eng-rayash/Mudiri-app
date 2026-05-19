import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/tasks_repository.dart';
import '../providers/tasks_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

/// Edit Task Screen
class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final int taskId;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;

  Priority? _selectedPriority;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _assignedToController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _initData(dynamic task) {
    if (_isInitialized) return;
    
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _assignedToController.text = task.assignedTo ?? '';
    _selectedPriority = Priority.fromValue(task.priority);
    
    if (task.dueDate != null && task.dueDate!.isNotEmpty) {
      _selectedDate = DateTime.tryParse(task.dueDate!);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPriority == null) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(tasksRepositoryProvider);
      
      await repository.updateTaskDetails(
        id: widget.taskId,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        priority: _selectedPriority!,
        dueDate: _selectedDate?.toIso8601String().split('T').first,
        assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التعديلات')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('تعديل المهمة', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطأ: $err')),
          data: (task) {
            if (task == null) return const Center(child: Text('المهمة غير موجودة'));
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _initData(task));
            });

            if (!_isInitialized) return const Center(child: CircularProgressIndicator());

            return Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.screen,
                children: [
                  NeuInput(
                    controller: _titleController,
                    label: 'عنوان المهمة',
                    prefixIcon: Icons.task_alt_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  AppSpacing.gapLg,

                  NeuInput(
                    controller: _descriptionController,
                    label: 'الوصف',
                    maxLines: 3,
                    prefixIcon: Icons.notes_rounded,
                  ),
                  AppSpacing.gapLg,

                  NeuInput(
                    controller: _assignedToController,
                    label: 'المسؤول التنفيذي',
                    prefixIcon: Icons.person_outline_rounded,
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
                            Text(_selectedDate != null ? DateFormat('d MMM yyyy', 'ar').format(_selectedDate!) : 'حدد التاريخ', style: AppTypography.body),
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
