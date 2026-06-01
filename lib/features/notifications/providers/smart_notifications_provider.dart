import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../tasks/providers/tasks_provider.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../directives/providers/directives_provider.dart';
import '../../followups/providers/follow_ups_provider.dart';
import '../domain/notification_service.dart';

/// Background scheduler provider that automatically keeps local reminders in sync with actual DB state.
final smartNotificationsSchedulerProvider = Provider<void>((ref) {
  // Watch the underlying data lists.
  // Whenever any task, meeting, directive, or follow-up changes, this provider will re-evaluate.
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  final meetings = ref.watch(meetingsListProvider).valueOrNull ?? [];
  final directives = ref.watch(directivesListProvider).valueOrNull ?? [];
  final followUps = ref.watch(followUpsListProvider).valueOrNull ?? [];

  // 1. Pending Tasks (status != 3/completed)
  final pendingTasks = tasks.where((t) => t.status != 3).toList();

  // 2. Meetings for today and tomorrow (status != 2/completed and status != 4/cancelled)
  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final tomorrowStr = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));

  final todayMeetings = meetings
      .where((m) => m.date == todayStr && m.status != 2 && m.status != 4)
      .toList();
  final tomorrowMeetings = meetings
      .where((m) => m.date == tomorrowStr && m.status != 2 && m.status != 4)
      .toList();

  // 3. Pending Directives (status != 3/completed)
  final pendingDirectives = directives.where((d) => d.status != 3).toList();

  // 4. Pending Follow-ups (status != 3/completed)
  final pendingFollowUps = followUps.where((f) => f.status != 3).toList();

  final notificationService = ref.read(notificationServiceProvider);

  // Defer execution slightly to avoid blocking the UI thread or running during a build phase.
  Future.microtask(() async {
    await notificationService.scheduleSmartExecutiveReminders(
      pendingTasks: pendingTasks,
      upcomingMeetings: todayMeetings,
      pendingDirectives: pendingDirectives,
      pendingFollowUps: pendingFollowUps,
      tomorrowMeetings: tomorrowMeetings,
    );
  });
});
