import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../backup/domain/backup_service.dart';
import '../../reports/domain/export_service.dart';
import '../../reports/providers/reports_provider.dart';

/// Advanced Settings Screen — comprehensive settings organized in sections.
///
/// Sections:
/// 1. Security & Protection
/// 2. Appearance
/// 3. Data & Export
/// 4. Notifications (placeholder for future)
/// 5. Application Info
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _notificationsEnabled = true;
  bool _overdueAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authService = AuthService.instance;
    _biometricAvailable = await authService.isBiometricAvailable();
    final method = await authService.getPreferredAuthMethod();
    _biometricEnabled = method == 0 && _biometricAvailable;

    final storage = SecureStorageService.instance;
    final notificationsVal = await storage.read('notifications_enabled');
    final overdueVal = await storage.read('overdue_alerts_enabled');

    _notificationsEnabled = notificationsVal != 'false';
    _overdueAlertsEnabled = overdueVal != 'false';

    if (mounted) setState(() {});
  }

  Future<void> _toggleBiometric(bool value) async {
    final authService = AuthService.instance;
    if (value) {
      final ok = await authService.authenticateWithBiometrics();
      if (ok) {
        await authService.setPreferredAuthMethod(0);
        setState(() => _biometricEnabled = true);
      }
    } else {
      await authService.setPreferredAuthMethod(1);
      setState(() => _biometricEnabled = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final storage = SecureStorageService.instance;
    await storage.write('notifications_enabled', value.toString());
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggleOverdueAlerts(bool value) async {
    final storage = SecureStorageService.instance;
    await storage.write('overdue_alerts_enabled', value.toString());
    setState(() => _overdueAlertsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'الإعدادات',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Section 1: Security ───
              _buildSectionTitle(
                  'الحماية والأمان', Icons.shield_rounded, isDark),
              AppSpacing.gapMd,

              // Biometric toggle
              if (_biometricAvailable)
                _buildToggleTile(
                  isDark,
                  icon: Icons.fingerprint_rounded,
                  title: 'تفعيل البصمة',
                  subtitle: 'استخدم البصمة للدخول السريع',
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                ),

              _buildNavigationTile(
                isDark,
                icon: Icons.lock_rounded,
                title: 'تغيير رمز الدخول',
                subtitle: 'تحديث رمز PIN الحالي',
                onTap: () => context.push(RouteNames.changePin),
              ),

              _buildNavigationTile(
                isDark,
                icon: Icons.history_rounded,
                title: 'سجل الأنشطة الأمنية',
                subtitle: 'عرض سجل تسجيلات الدخول',
                onTap: () {},
              ),

              AppSpacing.gapXxl,

              // ─── Section 2: Appearance ───
              _buildSectionTitle(
                  'المظهر', Icons.palette_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وضع العرض',
                      style: isDark
                          ? AppTypography.h4Dark
                          : AppTypography.h4,
                    ),
                    AppSpacing.gapMd,
                    Row(
                      children: [
                        _buildThemeOption(
                          isDark,
                          'فاتح',
                          Icons.light_mode_rounded,
                          themeMode == ThemeMode.light,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.light),
                        ),
                        AppSpacing.gapHMd,
                        _buildThemeOption(
                          isDark,
                          'داكن',
                          Icons.dark_mode_rounded,
                          themeMode == ThemeMode.dark,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.dark),
                        ),
                        AppSpacing.gapHMd,
                        _buildThemeOption(
                          isDark,
                          'تلقائي',
                          Icons.settings_brightness_rounded,
                          themeMode == ThemeMode.system,
                          () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXxl,

              // ─── Section 3: Data & Export ───
              _buildSectionTitle(
                  'البيانات والتصدير', Icons.storage_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'إدارة النسخ الاحتياطي والتصدير',
                      style: isDark
                          ? AppTypography.bodyDark
                          : AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapLg,
                    Row(
                      children: [
                        Expanded(
                          child: NeuButton(
                            label: 'إنشاء نسخة',
                            icon: Icons.backup_rounded,
                            variant: NeuButtonVariant.primary,
                            onPressed: () async {
                              await ref
                                  .read(backupServiceProvider)
                                  .exportBackup();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'تم إنشاء النسخة الاحتياطية بنجاح'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: NeuButton(
                            label: 'استعادة',
                            icon: Icons.restore_rounded,
                            variant: NeuButtonVariant.gold,
                            onPressed: () async {
                              final success = await ref
                                  .read(backupServiceProvider)
                                  .restoreBackup();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'تمت الاستعادة بنجاح. أعد تشغيل التطبيق.'
                                        : 'فشلت عملية الاستعادة.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapMd,
                    SizedBox(
                      width: double.infinity,
                      child: NeuButton(
                        label: 'تصدير التقرير اليومي',
                        icon: Icons.ios_share_rounded,
                        variant: NeuButtonVariant.secondary,
                        onPressed: () async {
                          final analytics =
                              ref.read(reportsAnalyticsProvider);
                          await ref
                              .read(exportServiceProvider)
                              .exportDailyReport(analytics);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapMd,

              // Delete all data
              _buildNavigationTile(
                isDark,
                icon: Icons.delete_forever_rounded,
                title: 'حذف جميع البيانات',
                subtitle: 'تحذير: لا يمكن التراجع عن هذا الإجراء',
                titleColor: NeuColors.danger,
                onTap: () => _confirmDeleteAll(context),
              ),

              AppSpacing.gapXxl,

              // ─── Section 4: Notifications ───
              _buildSectionTitle(
                  'الإشعارات', Icons.notifications_rounded, isDark),
              AppSpacing.gapMd,

              _buildToggleTile(
                isDark,
                icon: Icons.notifications_active_rounded,
                title: 'تفعيل الإشعارات',
                subtitle: 'تذكيرات الاجتماعات والمهام',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),

              _buildToggleTile(
                isDark,
                icon: Icons.warning_rounded,
                title: 'تنبيهات المهام المتأخرة',
                subtitle: 'إشعار عند تأخر مهمة',
                value: _overdueAlertsEnabled,
                onChanged: _toggleOverdueAlerts,
              ),

              AppSpacing.gapXxl,

              // ─── Section 5: About ───
              _buildSectionTitle(
                  'عن التطبيق', Icons.info_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: NeuColors.navyDeep,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'م',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: NeuColors.textOnDark,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Text(
                      'مديري',
                      style: isDark
                          ? AppTypography.h3Dark
                          : AppTypography.h3,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'نظام إدارة تنفيذي احترافي',
                      style: isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmall,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'الإصدار 0.1.0 • بناء 1',
                      style: isDark
                          ? AppTypography.captionDark
                          : AppTypography.caption,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
        ),
        AppSpacing.gapHSm,
        Text(
          title,
          style: isDark ? AppTypography.h4Dark : AppTypography.h4,
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: isDark
                        ? AppTypography.bodyDark
                        : AppTypography.body),
                Text(subtitle,
                    style: isDark
                        ? AppTypography.captionDark
                        : AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: NeuColors.goldAccent,
            activeThumbColor: NeuColors.navyDeep,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return NeuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22,
              color: titleColor ??
                  (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: (isDark
                            ? AppTypography.bodyDark
                            : AppTypography.body)
                        .copyWith(color: titleColor)),
                Text(subtitle,
                    style: isDark
                        ? AppTypography.captionDark
                        : AppTypography.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, size: 24,
              color: isDark
                  ? NeuColors.textHintDark
                  : NeuColors.textHint),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    bool isDark,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? NeuColors.navyDeep
                    : NeuColors.navyDeep.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? NeuColors.navyDeep
                  : (isDark ? NeuColors.dividerDark : NeuColors.divider),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? (isDark
                          ? NeuColors.goldAccent
                          : NeuColors.navyDeep)
                      : (isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint),
                  size: 24),
              AppSpacing.gapXs,
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? (isDark
                            ? NeuColors.goldAccent
                            : NeuColors.navyDeep)
                        : (isDark
                            ? NeuColors.textHintDark
                            : NeuColors.textHint),
                    fontFamily: 'Tajawal',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف جميع البيانات',
              style: AppTypography.h3),
          content: const Text(
            'هل أنت متأكد من حذف جميع البيانات؟ هذا الإجراء لا يمكن التراجع عنه.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
              ),
              onPressed: () {
                // Double confirmation
                Navigator.pop(ctx);
                _secondConfirm(context);
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _secondConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد نهائي',
              style: AppTypography.h3),
          content: const Text(
            'سيتم حذف جميع البيانات نهائيًا. هل تريد المتابعة؟',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
              ),
              onPressed: () async {
                await SecureStorageService.instance.deleteAll();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('تم حذف جميع البيانات. أعد تشغيل التطبيق.'),
                    ),
                  );
                }
              },
              child: const Text('حذف نهائي'),
            ),
          ],
        ),
      ),
    );
  }
}
