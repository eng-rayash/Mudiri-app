import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../domain/contacts_repository.dart';

/// Screen displaying the list of executive contacts with search & filter.
class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState
    extends ConsumerState<ContactsListScreen> {
  String _searchQuery = '';
  String _vipFilter = 'all';

  static const _filters = [
    FilterOption(label: 'الكل', value: 'all'),
    FilterOption(label: 'VIP', value: 'vip', icon: Icons.star_rounded),
    FilterOption(label: 'عادي', value: 'normal'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contactsAsync = ref.watch(contactsListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text('جهات الاتصال',
            style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter
            SearchFilterBar(
              searchHint: 'بحث في جهات الاتصال...',
              onSearchChanged: (q) =>
                  setState(() => _searchQuery = q),
              filters: _filters,
              selectedFilter: _vipFilter,
              onFilterChanged: (v) =>
                  setState(() => _vipFilter = v),
            ),
            AppSpacing.gapMd,

            // Contacts List
            Expanded(
              child: contactsAsync.when(
                data: (contacts) {
                  var filtered = contacts.toList();

                  // VIP filter
                  if (_vipFilter == 'vip') {
                    filtered = filtered
                        .where((c) => c.isVip)
                        .toList();
                  } else if (_vipFilter == 'normal') {
                    filtered = filtered
                        .where((c) => !c.isVip)
                        .toList();
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered.where((c) {
                      return c.name
                              .toLowerCase()
                              .contains(q) ||
                          (c.position ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (c.company ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (c.phoneNumber ?? '').contains(q) ||
                          (c.email ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty ||
                                _vipFilter != 'all'
                            ? 'لا توجد نتائج مطابقة'
                            : 'لا توجد جهات اتصال مضافة حتى الآن',
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
                      final contact = filtered[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 16),
                        child: NeuCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isDark
                                    ? NeuColors.surfaceDark
                                    : NeuColors.surface,
                                radius: 24,
                                child: Text(
                                  contact.name.characters.first,
                                  style: TextStyle(
                                    color: contact.isVip
                                        ? NeuColors
                                            .priorityCritical
                                        : (isDark
                                            ? NeuColors
                                                .goldAccent
                                            : NeuColors
                                                .navyDeep),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            contact.name,
                                            style: (isDark
                                                    ? AppTypography
                                                        .h3Dark
                                                    : AppTypography
                                                        .h3)
                                                .copyWith(
                                                    fontSize:
                                                        18),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        ),
                                        if (contact.isVip)
                                          const Icon(
                                              Icons
                                                  .star_rounded,
                                              color: NeuColors
                                                  .priorityCritical,
                                              size: 18),
                                      ],
                                    ),
                                    if (contact.position !=
                                            null ||
                                        contact.company !=
                                            null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${contact.position ?? ''} ${contact.company != null ? '- ${contact.company}' : ''}',
                                        style: (isDark
                                                ? AppTypography
                                                    .bodySmallDark
                                                : AppTypography
                                                    .bodySmall)
                                            .copyWith(
                                          color: isDark
                                              ? NeuColors
                                                  .textSecondaryDark
                                              : NeuColors
                                                  .textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ],
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
                        'خطأ في جلب جهات الاتصال: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(RouteNames.contactCreate),
        backgroundColor: NeuColors.navyDeep,
        child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white),
      ),
    );
  }
}
