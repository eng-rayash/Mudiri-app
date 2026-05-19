import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/search_filter_bar.dart';

import '../../../core/constants/enums.dart';
import '../../meetings/providers/meetings_provider.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/neu_card.dart';

/// Encounters List Screen — اللقاءات
class EncountersListScreen extends ConsumerStatefulWidget {
  const EncountersListScreen({super.key});

  @override
  ConsumerState<EncountersListScreen> createState() => _EncountersListScreenState();
}

class _EncountersListScreenState extends ConsumerState<EncountersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsState = ref.watch(meetingsListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'اللقاءات السريعة',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
            onPressed: () => context.push(RouteNames.encounterCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            SearchFilterBar(
              searchHint: 'بحث في اللقاءات...',
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: meetingsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('خطأ: $err')),
                data: (meetings) {
                  var filtered = meetings.where((m) => m.meetingType == MeetingType.external_.value).toList();

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((m) {
                      return m.title.toLowerCase().contains(q) ||
                          (m.location ?? '').toLowerCase().contains(q) ||
                          (m.objective ?? '').toLowerCase().contains(q) ||
                          (m.notes ?? '').toLowerCase().contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة' : 'لا توجد لقاءات مسجلة',
                        style: AppTypography.body.copyWith(
                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screenH,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final meeting = filtered[index];
                      return GestureDetector(
                        onTap: () => context.push(RouteNames.meetingDetailPath(meeting.id)),
                        child: NeuCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      meeting.title,
                                      style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  StatusBadge.fromMeetingStatus(meeting.status),
                                ],
                              ),
                              AppSpacing.gapSm,
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                  AppSpacing.gapHSm,
                                  Text(meeting.date,
                                      style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                  AppSpacing.gapHMd,
                                  Icon(Icons.access_time_rounded,
                                      size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                  AppSpacing.gapHSm,
                                  Text(meeting.time,
                                      style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

