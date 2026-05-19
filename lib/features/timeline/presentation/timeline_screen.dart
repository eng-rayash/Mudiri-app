import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../providers/timeline_provider.dart';

/// Timeline Screen — Phase 4
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(timelineProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('المخطط الزمني لليوم', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: events.isEmpty
          ? const Center(child: Text('لا توجد أحداث مجدولة لليوم', style: AppTypography.body))
          : ListView.builder(
              padding: AppSpacing.screen,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Column
                      SizedBox(
                        width: 60,
                        child: Text(
                          event.time,
                          style: AppTypography.h4.copyWith(color: NeuColors.navyMid),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Timeline line & dot
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: event.isCompleted ? NeuColors.success : NeuColors.goldAccent,
                              border: Border.all(color: NeuColors.bgColor, width: 2),
                            ),
                          ),
                          if (index != events.length - 1)
                            Container(
                              width: 2,
                              height: 60,
                              color: NeuColors.navyMid.withValues(alpha: 0.3),
                            ),
                        ],
                      ),
                      
                      AppSpacing.gapHMd,
                      
                      // Event Card
                      Expanded(
                        child: NeuCard(
                          padding: const EdgeInsets.all(16),
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                              AppSpacing.gapXs,
                              Text(_getEventTypeName(event.type), style: AppTypography.caption),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  String _getEventTypeName(String type) {
    switch (type) {
      case 'meeting':
        return 'اجتماع';
      case 'task':
        return 'مهمة';
      case 'appointment':
        return 'موعد';
      case 'call':
        return 'مكالمة هاتفية';
      default:
        return 'حدث';
    }
  }
}
