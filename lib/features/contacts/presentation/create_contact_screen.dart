import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/contacts_repository.dart';

/// Screen for creating a new contact
class CreateContactScreen extends ConsumerStatefulWidget {
  const CreateContactScreen({super.key});

  @override
  ConsumerState<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends ConsumerState<CreateContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isVip = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(contactsRepositoryProvider);
      await repository.createContact(
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        company: _companyController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        isVip: _isVip,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة جهة الاتصال بنجاح')),
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
    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('إضافة جهة اتصال', style: AppTypography.h3),
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
                controller: _nameController,
                label: 'الاسم الكامل *',
                hint: 'أدخل الاسم',
                prefixIcon: Icons.person_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'حقل مطلوب' : null,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _positionController,
                label: 'المنصب / الصفة',
                hint: 'مثال: المدير التنفيذي',
                prefixIcon: Icons.badge_rounded,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _companyController,
                label: 'الجهة / الشركة',
                hint: 'اسم الشركة',
                prefixIcon: Icons.business_rounded,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: 'رقم للتواصل',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'البريد',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              AppSpacing.gapXxl,
              
              // VIP Toggle
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, 
                          color: _isVip ? NeuColors.priorityCritical : NeuColors.textHint),
                        const SizedBox(width: 12),
                        const Text(
                          'جهة اتصال VIP',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isVip,
                      onChanged: (val) => setState(() => _isVip = val),
                      activeThumbColor: NeuColors.priorityCritical,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapXxl,
              NeuButton(
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
                label: 'حفظ جهة الاتصال',
                icon: Icons.check_rounded,
              ),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
