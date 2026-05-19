import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/contacts_repository.dart';

/// Screen displaying the list of executive contacts.
class ContactsListScreen extends ConsumerWidget {
  const ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: NeuColors.bgColor,
        elevation: 0,
        title: const Text('جهات الاتصال', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد جهات اتصال مضافة حتى الآن',
                  style: AppTypography.body.copyWith(color: NeuColors.textHint),
                ),
              );
            }

            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeuCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: NeuColors.surface,
                          radius: 24,
                          child: Text(
                            contact.name.characters.first,
                            style: TextStyle(
                              color: contact.isVip ? NeuColors.priorityCritical : NeuColors.navyDeep,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact.name,
                                      style: AppTypography.h3.copyWith(fontSize: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (contact.isVip)
                                    Icon(Icons.star_rounded, color: NeuColors.priorityCritical, size: 18),
                                ],
                              ),
                              if (contact.position != null || contact.company != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${contact.position ?? ''} ${contact.company != null ? '- ${contact.company}' : ''}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: NeuColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('خطأ في جلب جهات الاتصال: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.contactCreate),
        backgroundColor: NeuColors.navyDeep,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }
}
