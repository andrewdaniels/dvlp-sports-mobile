import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/help/ui/how_it_works_sheet.dart';
import '../../features/journal/ui/widgets/journal_summary_card.dart';
import '../../features/skills/controllers/skills_providers.dart';
import '../../features/skills/ui/sheets/skill_detail_sheet.dart';
import '../../features/skills/ui/widgets/skill_row.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

/// Development ("DVLP") tab. Two sections:
///   - My Journal — entry-point card at the top. Backend not built
///     yet; entry count stubbed at 0 until journal endpoints ship.
///   - My Skills — per-skill weighted-average progress from
///     `get-skill-progress`. Endpoint derives the athlete's active
///     team's level_classification server-side (single-active is
///     enforced by a DB partial unique index).
///
/// App bar has a trailing "How it works" icon opening the shared
/// scoring explainer — same sheet accessed from the skill detail
/// drill-in, wired here so the explanation is discoverable from the
/// top of the tab too.
class DvlpPage extends ConsumerWidget {
  const DvlpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Development'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppIconButton(
              icon: AppIcons.messageQuestionSquare,
              size: AppIconButtonSize.large,
              onPressed: () => showHowItWorksSheet(context),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _DvlpBody(athleteId: profile.id);
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

class _DvlpBody extends ConsumerWidget {
  const _DvlpBody({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(skillProgressProvider(athleteId));

    return AppRefreshIndicator(
      onRefresh: () => ref.read(skillProgressProvider(athleteId).notifier).refresh(),
      child: ListView(
        padding: AppPageInsets.padding,
        children: [
          // ── My Journal ─────────────────────────────────────
          // Entry count + navigation live inside the card via the
          // shared journalEntriesProvider.
          JournalSummaryCard(athleteId: athleteId),
          const SizedBox(height: AppSpacing.lg),

          // ── My Skills ──────────────────────────────────────
          Text(
            'My Skills',
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          ...async.when(
            data: (data) {
              if (data == null || data.skills.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      'No skill scores yet. Come back after your first formal assessment.',
                      style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                    ),
                  ),
                ];
              }
              return [
                for (var i = 0; i < data.skills.length; i++) ...[
                  SkillRow(
                    skill: data.skills[i],
                    scoreScale: data.scoreScale,
                    onTap: () => showSkillDetailSheet(
                      context,
                      skill: data.skills[i],
                      athleteId: athleteId,
                    ),
                  ),
                  if (i < data.skills.length - 1) const SizedBox(height: AppSpacing.sm),
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
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  'Something went wrong loading your skills.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
