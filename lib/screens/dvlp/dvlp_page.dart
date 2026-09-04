import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/skills/controllers/skills_providers.dart';
import '../../features/skills/ui/sheets/skill_detail_sheet.dart';
import '../../features/skills/ui/widgets/skill_row.dart';

/// Development ("DVLP") tab. Two sections planned:
///   - My Journal — not built yet (no backend). Placeholder deferred.
///   - My Skills — per-skill weighted-average progress from
///     `get-skill-progress`. Endpoint derives the athlete's active
///     team's level_classification server-side (single-active is
///     enforced by a DB partial unique index).
///
/// Journal + tap-to-open-progress-sheet are follow-ups.
class DvlpPage extends ConsumerWidget {
  const DvlpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Development')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _SkillsSection(athleteId: profile.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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

class _SkillsSection extends ConsumerWidget {
  const _SkillsSection({required this.athleteId});
  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(skillProgressProvider(athleteId));

    return RefreshIndicator(
      onRefresh: () => ref.read(skillProgressProvider(athleteId).notifier).refresh(),
      child: ListView(
        padding: AppPageInsets.padding,
        children: [
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
                child: Center(child: CircularProgressIndicator()),
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
