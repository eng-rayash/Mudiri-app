import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    try {
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );
      _initialized = true;
      
      // Auto schedule staggered alerts
      await scheduleStaggeredAlerts();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  Future<void> scheduleStaggeredAlerts() async {
    if (!_initialized) await init();

    try {
      // 1. Morning Review (08:00 AM)
      final now = DateTime.now();
      var morning = DateTime(now.year, now.month, now.day, 8, 0);
      if (morning.isBefore(now)) morning = morning.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 800,
        title: 'تخطيط اليوم التنفيذي ☀️',
        body: 'سعادة المدير، ابدأ يومك بالاطلاع على قائمة الاجتماعات والمهام اليومية المجدولة.',
        scheduledDate: tz.TZDateTime.from(morning, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Midday Follow-up (02:00 PM)
      var midday = DateTime(now.year, now.month, now.day, 14, 0);
      if (midday.isBefore(now)) midday = midday.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 801,
        title: 'متابعة الإنجاز والمصفوفة 📊',
        body: 'الوقوف على نسب إنجاز المهام والمتابعات المعلقة لضمان سير العمل بكفاءة.',
        scheduledDate: tz.TZDateTime.from(midday, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 3. Evening Review (08:00 PM)
      var evening = DateTime(now.year, now.month, now.day, 20, 0);
      if (evening.isBefore(now)) evening = evening.add(const Duration(days: 1));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 802,
        title: 'ملخص اليوم والإنجاز 🌙',
        body: 'مراجعة سريعة لما تم إنجازه اليوم وتجهيز الأولويات لصباح الغد المشرق.',
        scheduledDate: tz.TZDateTime.from(evening, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_staggered',
            'Mudiri Daily Staggered Alert',
            channelDescription: 'التنبيهات الإدارية المتفاوتة اليومية',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      debugPrint('Staggered notifications scheduled successfully.');
    } catch (e) {
      debugPrint('NotificationService.scheduleStaggeredAlerts error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }
    
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'mudiri_main_channel',
        'Mudiri Main Channel',
        channelDescription: 'تنبيهات تطبيق مديري',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      
      await _flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('NotificationService.showNotification error: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) {
      await init();
    }
    
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_scheduled',
            'Mudiri Scheduled',
            channelDescription: 'تنبيهات المواعيد المجدولة',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleNotification error: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
