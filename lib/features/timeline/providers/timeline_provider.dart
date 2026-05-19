import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../appointments/domain/appointments_repository.dart';
import '../../calls/domain/calls_repository.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../visitors/domain/visitors_repository.dart';
import '../../movements/domain/movements_repository.dart';
import '../../directives/providers/directives_provider.dart';

/// Represents a single event on the timeline
class TimelineEvent {
  final int? id;
  final String title;
  final String time;
  final String type; // 'meeting', 'visitor', 'movement', 'appointment', 'task', 'call', 'directive'
  final bool isCompleted;

  TimelineEvent({
    this.id,
    required this.title,
    required this.time,
    required this.type,
    this.isCompleted = false,
  });
}

/// Provider that aggregates events for the daily timeline
final timelineProvider = Provider<List<TimelineEvent>>((ref) {
  final events = <TimelineEvent>[];

  String formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('HH:mm').format(dt);
  }

  // 1. Meetings (الاجتماعات)
  final meetings = ref.watch(todayMeetingsProvider).valueOrNull ?? [];
  for (final m in meetings) {
    events.add(TimelineEvent(
      id: m.id,
      title: m.title,
      time: m.time,
      type: 'meeting',
      isCompleted: m.status == 2, // 2: Completed
    ));
  }

  // 2. Visitors (اللقاءات / الزوار)
  final visitors = ref.watch(activeVisitorsProvider).valueOrNull ?? [];
  for (final v in visitors) {
    events.add(TimelineEvent(
      id: v.id,
      title: 'لقاء مع: ${v.visitorName}',
      time: v.entryTime ?? formatTimestamp(v.createdAt),
      type: 'visitor',
      isCompleted: v.status == 2, // 2: Left
    ));
  }

  // 3. Movements (التحركات)
  final movements = ref.watch(activeMovementsProvider).valueOrNull ?? [];
  for (final m in movements) {
    String typeStr = 'خروج';
    if (m.type == 1) typeStr = 'عودة';
    if (m.type == 2) typeStr = 'مهمة خارجية';
    
    events.add(TimelineEvent(
      id: m.id,
      title: '$typeStr إلى: ${m.destination}',
      time: m.time,
      type: 'movement',
      isCompleted: false,
    ));
  }

  // 4. Appointments (المواعيد)
  final appointments = ref.watch(appointmentsListProvider).valueOrNull ?? [];
  for (final a in appointments) {
    events.add(TimelineEvent(
      id: a.id,
      title: 'موعد: ${a.title}',
      time: a.time,
      type: 'appointment',
      isCompleted: false,
    ));
  }

  // 5. Tasks (المهام)
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  for (final t in tasks) {
    events.add(TimelineEvent(
      id: t.id,
      title: 'مهمة: ${t.title}',
      time: formatTimestamp(t.createdAt),
      type: 'task',
      isCompleted: t.status == 3, // 3: Completed (UnifiedStatus)
    ));
  }

  // 6. Calls (المكالمات)
  final calls = ref.watch(callsListProvider).valueOrNull ?? [];
  for (final c in calls) {
    events.add(TimelineEvent(
      id: c.id,
      title: 'مكالمة: ${c.callerName}',
      time: c.time,
      type: 'call',
      isCompleted: true,
    ));
  }

  // 7. Directives (التوجيهات)
  final directives = ref.watch(directivesListProvider).valueOrNull ?? [];
  for (final d in directives) {
    events.add(TimelineEvent(
      id: d.id,
      title: 'توجيه: ${d.title}',
      time: formatTimestamp(d.createdAt),
      type: 'directive',
      isCompleted: d.status == 3, // 3: Completed (UnifiedStatus)
    ));
  }

  // Sort events by time chronologically
  events.sort((a, b) => a.time.compareTo(b.time));

  return events;
});
