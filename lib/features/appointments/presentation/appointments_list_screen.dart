import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/appointments_repository.dart';

/// Screen displaying the list of appointments.
class AppointmentsListScreen extends ConsumerWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('المواعيد', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: appointmentsAsync.when(
          data: (appointments) {
            if (appointments.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد مواعيد مجدولة',
                  style: AppTypography.body.copyWith(color: NeuColors.textHint),
                ),
              );
            }

            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: NeuColors.navyMid.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                appointment.time,
                                style: AppTypography.h3.copyWith(
                                  color: NeuColors.navyDeep,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appointment.durationMinutes} دقيقة',
                                style: AppTypography.caption.copyWith(
                                  color: NeuColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Appointment Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.title,
                                style: AppTypography.h3.copyWith(fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: NeuColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(
                                    appointment.date,
                                    style: AppTypography.caption,
                                  ),
                                  if (appointment.location != null && appointment.location!.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                    const Icon(Icons.location_on_rounded, size: 14, color: NeuColors.textHint),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        appointment.location!,
                                        style: AppTypography.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('خطأ في جلب المواعيد: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.appointmentCreate),
        backgroundColor: NeuColors.navyDeep,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
