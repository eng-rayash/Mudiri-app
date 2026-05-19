import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../appointments/domain/appointments_repository.dart';
import '../../directives/providers/directives_provider.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../tasks/providers/tasks_provider.dart';

/// Reports Analytics Provider (Phase 3 Engine)
/// 
/// This acts as the Business Intelligence layer, reading from all 
/// repositories to generate insights without needing a separate table.
class ReportsAnalytics {
  final int totalMeetings;
  final int totalTasks;
  final int completedTasks;
  final int criticalDirectives;
  final int upcomingAppointments;

  ReportsAnalytics({
    required this.totalMeetings,
    required this.totalTasks,
    required this.completedTasks,
    required this.criticalDirectives,
    required this.upcomingAppointments,
  });

  double get taskCompletionRate => totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

final reportsAnalyticsProvider = Provider<ReportsAnalytics>((ref) {
  // Watch the streams natively through Riverpod providers
  final tasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  final meetings = ref.watch(meetingsListProvider).valueOrNull ?? [];
  final directives = ref.watch(directivesListProvider).valueOrNull ?? [];
  // For appointments, let's assume we have an appointmentsListProvider
  final appointments = ref.watch(appointmentsListProvider).valueOrNull ?? [];

  return ReportsAnalytics(
    totalMeetings: meetings.length,
    totalTasks: tasks.length,
    completedTasks: tasks.where((t) => t.status == 3).length, // 3 = completed
    criticalDirectives: directives.where((d) => d.priority == 0).length, // 0 = critical
    upcomingAppointments: appointments.length,
  );
});
