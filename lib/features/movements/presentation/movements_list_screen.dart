import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/search_filter_bar.dart';

import '../domain/movements_repository.dart';
import '../../../shared/widgets/neu_card.dart';

/// Movements List Screen — تحرك
class MovementsListScreen extends ConsumerStatefulWidget {
  const MovementsListScreen({super.key});

  @override
  ConsumerState<MovementsListScreen> createState() => _MovementsListScreenState();
}

class _MovementsListScreenState extends ConsumerState<MovementsListScreen> {
  String _searchQuery = '';

  static const List<String> _types = ['خروج', 'عودة', 'مهمة خارجية'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final movementsState = ref.watch(activeMovementsProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التحركات',
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
            onPressed: () => context.push(RouteNames.movementCreate),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            SearchFilterBar(
              searchHint: 'بحث في التحركات...',
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: movementsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('خطأ: $err')),
                data: (movements) {
                  var filtered = movements.toList();

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((m) {
                      return m.destination.toLowerCase().contains(q) ||
                          (m.purpose ?? '').toLowerCase().contains(q) ||
                          (m.notes ?? '').toLowerCase().contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة' : 'لا توجد تحركات مسجلة',
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
                      final movement = filtered[index];
                      final typeLabel = movement.type >= 0 && movement.type < _types.length 
                          ? _types[movement.type] 
                          : 'غير معروف';

                      return NeuCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    movement.destination,
                                    style: isDark ? AppTypography.h4Dark : AppTypography.h4,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withAlpha(20),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    typeLabel,
                                    style: AppTypography.caption.copyWith(
                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapSm,
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                AppSpacing.gapHSm,
                                Text(movement.date,
                                    style: isDark ? AppTypography.captionDark : AppTypography.caption),
                                AppSpacing.gapHMd,
                                Icon(Icons.access_time_rounded,
                                    size: 14, color: isDark ? NeuColors.textHintDark : NeuColors.navyMid),
                                AppSpacing.gapHSm,
                                Text(movement.time,
                                    style: isDark ? AppTypography.captionDark : AppTypography.caption),
                              ],
                            ),
                            if (movement.purpose != null && movement.purpose!.isNotEmpty) ...[
                              AppSpacing.gapSm,
                              Text(
                                'الغرض: ${movement.purpose}',
                                style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                  color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
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
