/// Core Constants & Enums for the Mudiri Application
///
/// Unified status and priority systems used across all features.
library;

// ─────────────────────────────────────────────
// Meeting Status
// ─────────────────────────────────────────────

/// نظام حالات الاجتماعات
enum MeetingStatus {
  /// مجدول — Scheduled
  scheduled(0, 'مجدول'),

  /// قيد التنفيذ — In Progress
  inProgress(1, 'قيد التنفيذ'),

  /// مكتمل — Completed
  completed(2, 'مكتمل'),

  /// مؤجل — Postponed
  postponed(3, 'مؤجل'),

  /// ملغي — Cancelled
  cancelled(4, 'ملغي');

  const MeetingStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static MeetingStatus fromValue(int value) =>
      MeetingStatus.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Meeting Type
// ─────────────────────────────────────────────

/// أنواع الاجتماعات
enum MeetingType {
  /// اجتماع عام — General
  general(0, 'اجتماع عام'),

  /// اجتماع إداري — Administrative
  administrative(1, 'اجتماع إداري'),

  /// اجتماع طوارئ — Emergency
  emergency(2, 'اجتماع طوارئ'),

  /// اجتماع مراجعة — Review
  review(3, 'اجتماع مراجعة'),

  /// اجتماع تخطيط — Planning
  planning(4, 'اجتماع تخطيط'),

  /// اجتماع متابعة — Follow-up
  followUp(5, 'اجتماع متابعة'),

  /// اجتماع خارجي — External
  external_(6, 'اجتماع خارجي');

  const MeetingType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static MeetingType fromValue(int value) =>
      MeetingType.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Unified Status System
// ─────────────────────────────────────────────

/// نظام الحالات الموحد — يُستخدم عبر جميع الوحدات
enum UnifiedStatus {
  /// جديد — New
  newItem(0, 'جديد'),

  /// قيد التنفيذ — In Progress
  inProgress(1, 'قيد التنفيذ'),

  /// بانتظار الرد — Awaiting Response
  awaitingResponse(2, 'بانتظار الرد'),

  /// مكتمل — Completed
  completed(3, 'مكتمل'),

  /// متأخر — Overdue
  overdue(4, 'متأخر'),

  /// متعثر — Stalled
  stalled(5, 'متعثر'),

  /// ملغي — Cancelled
  cancelled(6, 'ملغي');

  const UnifiedStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static UnifiedStatus fromValue(int value) =>
      UnifiedStatus.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Priority System
// ─────────────────────────────────────────────

/// نظام الأولويات
enum Priority {
  /// عاجل جدًا — Critical
  critical(0, 'عاجل جدًا'),

  /// عالي — High
  high(1, 'عالي'),

  /// متوسط — Medium
  medium(2, 'متوسط'),

  /// منخفض — Low
  low(3, 'منخفض');

  const Priority(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static Priority fromValue(int value) =>
      Priority.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Security Action Types
// ─────────────────────────────────────────────

/// أنواع الإجراءات الأمنية — Security Log
enum SecurityAction {
  login(0, 'تسجيل دخول'),
  failedLogin(1, 'محاولة دخول فاشلة'),
  logout(2, 'تسجيل خروج'),
  pinSetup(3, 'إعداد رمز PIN'),
  pinChanged(4, 'تغيير رمز PIN'),
  biometricEnabled(5, 'تفعيل البصمة'),
  biometricDisabled(6, 'إلغاء البصمة'),
  exportData(7, 'تصدير بيانات'),
  deleteRecord(8, 'حذف سجل'),
  backupCreated(9, 'إنشاء نسخة احتياطية'),
  backupRestored(10, 'استعادة نسخة احتياطية'),
  settingsChanged(11, 'تعديل الإعدادات'),
  appLocked(12, 'قفل التطبيق'),
  appUnlocked(13, 'فتح التطبيق');

  const SecurityAction(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static SecurityAction fromValue(int value) =>
      SecurityAction.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Auth Method
// ─────────────────────────────────────────────

/// طرق المصادقة
enum AuthMethod {
  /// بصمة — Biometric (priority)
  biometric(0, 'بصمة'),

  /// رمز PIN — PIN Code (fallback)
  pin(1, 'رمز PIN'),

  /// نمط — Pattern (optional, future)
  pattern(2, 'نمط');

  const AuthMethod(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static AuthMethod fromValue(int value) =>
      AuthMethod.values.firstWhere((e) => e.value == value);
}

// ─────────────────────────────────────────────
// Follow Up Entity Type
// ─────────────────────────────────────────────

/// نوع الكيان المرتبط بالمتابعة
enum FollowUpEntityType {
  meeting(0, 'اجتماع'),
  task(1, 'مهمة'),
  directive(2, 'توجيه'),
  other(3, 'أخرى');

  const FollowUpEntityType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static FollowUpEntityType fromValue(int value) =>
      FollowUpEntityType.values.firstWhere((e) => e.value == value);
}
