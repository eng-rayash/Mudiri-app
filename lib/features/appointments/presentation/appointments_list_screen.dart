import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/appointments_repository.dart';

/// Screen displaying the list of appointments with search & filter.
class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  ConsumerState<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState
    extends ConsumerState<AppointmentsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentsAsync = ref.watch(appointmentsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
          onPressed: () => context.pop(),
        ),
        title: Text('المواعيد',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search
            SearchFilterBar(
              searchHint: 'بحث في المواعيد...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,

            // List
            Expanded(
              child: appointmentsAsync.when(
                data: (appointments) {
                  var filtered = appointments.toList();

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((a) {
                      return a.title
                              .toLowerCase()
                              .contains(q) ||
                          (a.location ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          a.date.contains(q) ||
                          a.time.contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد مواعيد مجدولة',
                        style: AppTypography.body.copyWith(
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screen,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 16),
                        child: NeuCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Time Indicator
                              Container(
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? NeuColors.navyLight
                                          : NeuColors.navyMid)
                                      .withAlpha(25),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      appointment.time,
                                      style: (isDark
                                              ? AppTypography
                                                  .h3Dark
                                              : AppTypography.h3)
                                          .copyWith(
                                              fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${appointment.durationMinutes} دقيقة',
                                      style: isDark
                                          ? AppTypography
                                              .captionDark
                                          : AppTypography
                                              .caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.title,
                                      style: (isDark
                                              ? AppTypography
                                                  .h3Dark
                                              : AppTypography.h3)
                                          .copyWith(
                                              fontSize: 18),
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .calendar_today_rounded,
                                            size: 14,
                                            color: isDark
                                                ? NeuColors
                                                    .textHintDark
                                                : NeuColors
                                                    .textHint),
                                        const SizedBox(
                                            width: 4),
                                        Text(
                                            appointment.date,
                                            style: isDark
                                                ? AppTypography
                                                    .captionDark
                                                : AppTypography
                                                    .caption),
                                        if (appointment
                                                    .location !=
                                                null &&
                                            appointment
                                                .location!
                                                .isNotEmpty) ...[
                                          const SizedBox(
                                              width: 12),
                                          Icon(
                                              Icons
                                                  .location_on_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? NeuColors
                                                      .textHintDark
                                                  : NeuColors
                                                      .textHint),
                                          const SizedBox(
                                              width: 4),
                                          Expanded(
                                            child: Text(
                                                appointment
                                                    .location!,
                                                style: isDark
                                                    ? AppTypography
                                                        .captionDark
                                                    : AppTypography
                                                        .caption,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis),
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
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (error, _) => Center(
                    child: Text(
                        'خطأ في جلب المواعيد: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(RouteNames.appointmentCreate),
        backgroundColor: NeuColors.navyDeep,
        child: const Icon(Icons.add_rounded,
            color: Colors.white),
      ),
    );
  }
}
