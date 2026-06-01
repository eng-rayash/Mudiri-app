import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../core/database/app_database.dart';

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

  /// Dynamic Executive Reminders Engine based on actual database data
  Future<void> scheduleSmartExecutiveReminders({
    required List<Task> pendingTasks,
    required List<Meeting> upcomingMeetings,
    required List<Directive> pendingDirectives,
    required List<FollowUp> pendingFollowUps,
    required List<Meeting> tomorrowMeetings,
  }) async {
    if (!_initialized) await init();

    try {
      final now = DateTime.now();

      // Cancel previous dynamic notifications (IDs 900 to 904) to avoid duplicates
      await _flutterLocalNotificationsPlugin.cancel(id: 900);
      await _flutterLocalNotificationsPlugin.cancel(id: 901);
      await _flutterLocalNotificationsPlugin.cancel(id: 902);
      await _flutterLocalNotificationsPlugin.cancel(id: 903);
      await _flutterLocalNotificationsPlugin.cancel(id: 904);

      // 1. Morning Review (08:30 AM) - Urgent Task Reminder
      var morningTime = DateTime(now.year, now.month, now.day, 8, 30);
      if (morningTime.isBefore(now)) morningTime = morningTime.add(const Duration(days: 1));

      String morningTitle = 'مهام اليوم التنفيذية 📌';
      String morningBody = 'سعادة المدير، لا توجد مهام معلقة حالياً. يومك سعيد ومليء بالإنجاز!';
      if (pendingTasks.isNotEmpty) {
        // Sort by priority (critical/0 first) and due date
        final urgentTask = (List<Task>.from(pendingTasks)..sort((a, b) => a.priority.compareTo(b.priority))).first;
        String priorityStr = urgentTask.priority == 0 ? 'عاجلة جداً 🚨' : 'هامة ⭐';
        final assigned = urgentTask.assignedTo != null && urgentTask.assignedTo!.isNotEmpty
            ? ' مسندة لـ [${urgentTask.assignedTo}]'
            : '';
        final due = urgentTask.dueDate != null && urgentTask.dueDate!.isNotEmpty
            ? ' - تسليم: ${urgentTask.dueDate}'
            : '';
        morningBody = 'مهمة $priorityStr: "${urgentTask.title}"$assigned$due';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 900,
        title: morningTitle,
        body: morningBody,
        scheduledDate: tz.TZDateTime.from(morningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription: 'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Midmorning Meeting (10:30 AM) - Meeting Reminder
      var midmorningTime = DateTime(now.year, now.month, now.day, 10, 30);
      if (midmorningTime.isBefore(now)) midmorningTime = midmorningTime.add(const Duration(days: 1));

      String meetingTitle = 'الاجتماعات المجدولة اليوم 👥';
      String meetingBody = 'سعادة المدير، لا توجد اجتماعات معلنة اليوم. فرصة ممتازة للتركيز ومتابعة التقارير.';
      if (upcomingMeetings.isNotEmpty) {
        final nextMeeting = upcomingMeetings.first;
        final loc = nextMeeting.location != null && nextMeeting.location!.isNotEmpty
            ? ' في [${nextMeeting.location}]'
            : '';
        meetingBody = 'اجتماع قادم: "${nextMeeting.title}" في تمام الساعة ${nextMeeting.time}$loc';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 901,
        title: meetingTitle,
        body: meetingBody,
        scheduledDate: tz.TZDateTime.from(midmorningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription: 'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 3. Midday Follow-up (01:30 PM) - Followups Reminder
      var middayTime = DateTime(now.year, now.month, now.day, 13, 30);
      if (middayTime.isBefore(now)) middayTime = middayTime.add(const Duration(days: 1));

      String followUpTitle = 'متابعة العمل التنفيذي 🔄';
      String followUpBody = 'سعادة المدير، جميع المتابعات التنفيذية المسندة تسير بشكل طبيعي ودون تأخير.';
      if (pendingFollowUps.isNotEmpty) {
        final followUp = pendingFollowUps.first;
        final assigned = followUp.assignedTo != null && followUp.assignedTo!.isNotEmpty
            ? ' الموكلة للمسؤول [${followUp.assignedTo}]'
            : '';
        followUpBody = 'يرجى متابعة: "${followUp.title}"$assigned';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 902,
        title: followUpTitle,
        body: followUpBody,
        scheduledDate: tz.TZDateTime.from(middayTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription: 'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 4. Afternoon Directive (04:30 PM) - Directives Reminder
      var afternoonTime = DateTime(now.year, now.month, now.day, 16, 30);
      if (afternoonTime.isBefore(now)) afternoonTime = afternoonTime.add(const Duration(days: 1));

      String directiveTitle = 'التوجيهات التنفيذية القائمة 📋';
      String directiveBody = 'سعادة المدير، تم تسليم أو إنجاز كافة التوجيهات المسندة للأقسام.';
      if (pendingDirectives.isNotEmpty) {
        final directive = pendingDirectives.first;
        final assigned = directive.assignedTo != null && directive.assignedTo!.isNotEmpty
            ? ' لمتابعة [${directive.assignedTo}]'
            : '';
        final due = directive.deadline != null && directive.deadline!.isNotEmpty
            ? ' - تسليم: ${directive.deadline}'
            : '';
        directiveBody = 'توجيه قائم: "${directive.title}"$assigned$due';
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 903,
        title: directiveTitle,
        body: directiveBody,
        scheduledDate: tz.TZDateTime.from(afternoonTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription: 'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 5. Evening Harvest (08:30 PM) - Summary Alert
      var eveningTime = DateTime(now.year, now.month, now.day, 20, 30);
      if (eveningTime.isBefore(now)) eveningTime = eveningTime.add(const Duration(days: 1));

      String harvestTitle = 'الحصاد الإداري اليومي 📈';
      String harvestBody = 'تقرير المساء: سعادة المدير، لديك ${pendingTasks.length} مهام معلقة، و ${pendingDirectives.length} توجيهات قائمة، و ${tomorrowMeetings.length} اجتماعات مجدولة للغد.';

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 904,
        title: harvestTitle,
        body: harvestBody,
        scheduledDate: tz.TZDateTime.from(eveningTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mudiri_smart_reminders',
            'Mudiri Executive Smart Reminders',
            channelDescription: 'تذكيرات ذكية مستمرة للمهام والاجتماعات والتوجيهات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Smart Executive Reminders scheduled successfully.');
    } catch (e) {
      debugPrint('NotificationService.scheduleSmartExecutiveReminders error: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
