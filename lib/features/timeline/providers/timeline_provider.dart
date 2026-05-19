import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../appointments/domain/appointments_repository.dart';
import '../../calls/domain/calls_repository.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../tasks/providers/tasks_provider.dart';

/// Represents a single event on the timeline
class TimelineEvent {
  final String title;
  final String time;
  final String type; // e.g. 'meeting', 'task', 'call', 'appointment'
  final bool isCompleted;

  TimelineEvent({
    required this.title,
    required this.time,
    required this.type,
    this.isCompleted = false,
  });
}

/// Provider that aggregates events for the daily timeline
final timelineProvider = Provider<List<TimelineEvent>>((ref) {
  final events = <TimelineEvent>[];

  // 1. Get Meetings
  final meetings = ref.watch(todayMeetingsProvider).valueOrNull ?? [];
  for (final m in meetings) {
    events.add(TimelineEvent(
      title: m.title,
      time: m.time,
      type: 'meeting',
      isCompleted: m.status == 2, // 2: Completed
    ));
  }

  // 2. Get Tasks (Assuming we want tasks due today)
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  for (final t in tasks) {
    // For simplicity, we just add tasks with a dummy time or their due date if they had time.
    // Assuming tasks have a dueDate string like 'dd/MM/yyyy'.
    events.add(TimelineEvent(
      title: t.title,
      time: '08:00', // Default or parse from task
      type: 'task',
      isCompleted: t.status == 3, // 3: Completed
    ));
  }

  // 3. Get Appointments
  final appointments = ref.watch(appointmentsListProvider).valueOrNull ?? [];
  for (final a in appointments) {
    events.add(TimelineEvent(
      title: a.title,
      time: a.time,
      type: 'appointment',
      isCompleted: false, // Could add status to appointments later
    ));
  }

  // 4. Get Calls
  final calls = ref.watch(callsListProvider).valueOrNull ?? [];
  for (final c in calls) {
    events.add(TimelineEvent(
      title: 'مكالمة: ${c.callerName}',
      time: c.time,
      type: 'call',
      isCompleted: true, // Past calls are completed
    ));
  }

  // Sort events by time
  events.sort((a, b) => a.time.compareTo(b.time));

  return events;
});
