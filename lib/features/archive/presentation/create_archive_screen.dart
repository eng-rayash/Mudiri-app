import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/archive_repository.dart';

/// Screen for creating a new archive document entry
class CreateArchiveScreen extends ConsumerStatefulWidget {
  const CreateArchiveScreen({super.key});

  @override
  ConsumerState<CreateArchiveScreen> createState() => _CreateArchiveScreenState();
}

class _CreateArchiveScreenState extends ConsumerState<CreateArchiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _refNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isConfidential = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _refNumberController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(archiveRepositoryProvider);

      await repository.createArchiveRecord(
        title: _titleController.text.trim(),
        referenceNumber: _refNumberController.text.trim(),
        documentDate: _dateController.text.trim(),
        category: _categoryController.text.trim(),
        tags: _tagsController.text.trim(),
        isConfidential: _isConfidential,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم أرشفة الوثيقة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('أرشفة وثيقة', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
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
                label: 'عنوان الوثيقة *',
                hint: 'أدخل عنوان أو وصف الوثيقة',
                prefixIcon: Icons.title_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'حقل مطلوب' : null,
              ),
              AppSpacing.gapLg,
              
              NeuInput(
                controller: _refNumberController,
                label: 'الرقم المرجعي (صادر/وارد)',
                hint: 'مثال: ص-1445-123',
                prefixIcon: Icons.tag_rounded,
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _dateController,
                label: 'تاريخ الوثيقة',
                hint: 'مثال: 10/05/2026',
                prefixIcon: Icons.calendar_today_rounded,
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _categoryController,
                label: 'التصنيف',
                hint: 'إداري، مالي، قانوني...',
                prefixIcon: Icons.category_rounded,
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _tagsController,
                label: 'الكلمات المفتاحية',
                hint: 'افصل بين الكلمات بفاصلة (،)',
                prefixIcon: Icons.label_rounded,
              ),
              AppSpacing.gapXxl,
              
              // Confidential Toggle
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_rounded, 
                          color: _isConfidential ? NeuColors.priorityCritical : NeuColors.textHint),
                        const SizedBox(width: 12),
                        Text(
                          'وثيقة سريّة',
                          style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isConfidential,
                      onChanged: (val) => setState(() => _isConfidential = val),
                      activeThumbColor: NeuColors.priorityCritical,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapXxl,
              NeuButton(
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
                label: 'حفظ الوثيقة',
                icon: Icons.save_rounded,
              ),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
