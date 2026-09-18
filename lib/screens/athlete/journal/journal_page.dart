import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/journal/controllers/journal_providers.dart';
import '../../../features/journal/ui/sheets/journal_entry_detail_sheet.dart';
import '../../../features/journal/ui/sheets/journal_entry_form_sheet.dart';
import '../../../features/journal/ui/widgets/journal_entry_row.dart';
import '../../../generated/api/get_journal_entries.dart';
import '../../../generated/api/get_profile.dart' show RoleTier;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_detail_app_bar.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';

/// Full-screen destination pushed from the DVLP → My Journal card.
///
/// New Entry button and row-tap detail sheet are deferred to
/// follow-ups (need create-journal-entry endpoint + entry-detail
/// design respectively).
class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // Show the viewing-athlete's journal (own for an athlete session,
    // linked athlete's for a guardian). New Entry stays gated on
    // caller role below — only athletes can create entries.
    final profileAsync = ref.watch(viewingAthleteProvider);

    return Scaffold(
      appBar: const AppDetailAppBar(title: 'My Journal'),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _JournalBody(athleteId: profile.id);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Something went wrong.',
            style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
          ),
        ),
      ),
    );
  }
}

class _JournalBody extends ConsumerWidget {
  const _JournalBody({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(journalEntriesProvider(athleteId));

    return AppRefreshIndicator(
      onRefresh: () => ref.read(journalEntriesProvider(athleteId).notifier).refresh(),
      child: ListView(
        padding: AppPageInsets.padding,
        children: [
          // Full-width primary CTA. Journal is athlete-authored —
          // guardians view the entries but can't create them. Server
          // also ownership-checks on create-journal-entry; the
          // disabled state is UX to match.
          Builder(
            builder: (context) {
              final caller = ref.watch(currentProfileProvider).value;
              final isAthlete = caller?.roleTier == RoleTier.ATHLETE;
              return AppButton(
                label: 'New Entry',
                leadingIcon: AppIcons.plus,
                expand: true,
                onPressed: isAthlete
                    ? () => showJournalEntryFormSheet(context, athleteId: athleteId)
                    : null,
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ...async.when(
            data: (data) {
              final entries = data?.entries ?? const <Entry>[];
              if (entries.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: AppEmptyState(
                      icon: AppIcons.edit05,
                      iconColor: colors.secondaryText,
                      title: 'No journal entries yet',
                      subtitle:
                          'Reflections and takeaways from practice and games will appear here.',
                    ),
                  ),
                ];
              }
              return [
                Text(
                  _entriesLabel(entries.length),
                  style: AppTypography.titleSmall.copyWith(color: colors.primaryText),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < entries.length; i++) ...[
                  JournalEntryRow(
                    entry: entries[i],
                    onTap: () => showJournalEntryDetailSheet(context, entry: entries[i]),
                  ),
                  if (i < entries.length - 1) const SizedBox(height: AppSpacing.sm),
                ],
              ];
            },
            loading: () => [
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: Center(child: AppLoadingIndicator()),
              ),
            ],
            error: (_, _) => [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Text(
                  'Could not load your journal entries.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _entriesLabel(int count) => count == 1 ? '1 entry' : '$count entries';
}
