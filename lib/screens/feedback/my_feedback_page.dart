import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../features/assessments/controllers/assessments_providers.dart';
import '../../features/assessments/ui/widgets/team_feedback_section.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../generated/api/get_assessments.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_detail_app_bar.dart';

/// Full-screen destination pushed from Passport's "See All" link.
/// Shows the athlete's entire submitted-feedback history across
/// every team + level, grouped into expandable per-team sections
/// and filtered by "chapter" chips (per-athlete level labels).
///
/// Chapter derivation is per-athlete and index-based: sort the
/// athlete's attended levels by `tier_order` ASC, assign CH1, CH2,
/// … in that order. Athlete who skipped SingleA sees their lowest
/// attended level as CH1.
///
/// No new provider — reads the same `assessmentsProvider(athleteId)`
/// as Passport, already warmed by that page. All grouping / sorting
/// / filtering is client-side.
class MyFeedbackPage extends ConsumerStatefulWidget {
  const MyFeedbackPage({super.key});

  @override
  ConsumerState<MyFeedbackPage> createState() => _MyFeedbackPageState();
}

class _MyFeedbackPageState extends ConsumerState<MyFeedbackPage> {
  /// Selected level_classification.id, or null for "All".
  String? _selectedLevelId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: const AppDetailAppBar(title: 'My Feedback'),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _Body(
            athleteId: profile.id,
            selectedLevelId: _selectedLevelId,
            onSelectLevel: (id) => setState(() => _selectedLevelId = id),
          );
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

class _Body extends ConsumerWidget {
  const _Body({
    required this.athleteId,
    required this.selectedLevelId,
    required this.onSelectLevel,
  });

  final String athleteId;
  final String? selectedLevelId;
  final ValueChanged<String?> onSelectLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(assessmentsProvider(athleteId));

    return async.when(
      data: (data) {
        final all = data?.assessments ?? const <Assessment>[];
        if (all.isEmpty) {
          return Center(
            child: Padding(
              padding: AppPageInsets.padding,
              child: Text(
                'No feedback yet.',
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
              ),
            ),
          );
        }
        return _FeedbackList(
          all: all,
          selectedLevelId: selectedLevelId,
          onSelectLevel: onSelectLevel,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Padding(
          padding: AppPageInsets.padding,
          child: Text(
            'Could not load your feedback.',
            style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
          ),
        ),
      ),
    );
  }
}

class _FeedbackList extends StatelessWidget {
  const _FeedbackList({
    required this.all,
    required this.selectedLevelId,
    required this.onSelectLevel,
  });

  final List<Assessment> all;
  final String? selectedLevelId;
  final ValueChanged<String?> onSelectLevel;

  @override
  Widget build(BuildContext context) {
    final derived = _derive(all);

    // Filter the team list by the selected chapter (or show all).
    final visibleTeams = selectedLevelId == null
        ? derived.teamsInDisplayOrder
        : derived.teamsInDisplayOrder
            .where((t) => t.levelClassificationId == selectedLevelId)
            .toList();

    return ListView(
      padding: AppPageInsets.padding,
      children: [
        // ── Chapter chips ─────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              AppChip(
                label: 'All',
                selected: selectedLevelId == null,
                onTap: () => onSelectLevel(null),
              ),
              for (final chapter in derived.chapters) ...[
                const SizedBox(width: AppSpacing.sm),
                AppChip(
                  label: 'CH${chapter.index + 1}',
                  selected: selectedLevelId == chapter.levelId,
                  onTap: () => onSelectLevel(chapter.levelId),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Team sections ─────────────────────────────────────
        // AppExpandableSection owns its own bottom AppDivider so
        // sections stack directly with no gap between them.
        for (final team in visibleTeams)
          TeamFeedbackSection(
            teamName: team.teamName,
            ageGroup: team.ageGroup,
            levelName: team.levelName,
            assessments: team.assessments,
          ),
      ],
    );
  }

  // ─── Derivation ─────────────────────────────────────────────
  // Pure projection: input = list of assessments; output = chapters
  // (level groups sorted by tier_order) and teams (grouped by team.id,
  // sorted within a chapter by most-recent assessment).
  static _Derived _derive(List<Assessment> all) {
    // Group assessments by team.id.
    final byTeam = <String, List<Assessment>>{};
    final teamInfo = <String, _TeamInfo>{};
    for (final a in all) {
      final teamId = a.team.id;
      byTeam.putIfAbsent(teamId, () => []).add(a);
      teamInfo.putIfAbsent(
        teamId,
        () => _TeamInfo(
          teamId: teamId,
          teamName: a.team.name,
          ageGroup: a.team.ageGroup,
          levelId: a.team.levelClassification?.id ?? '',
          levelName: a.team.levelClassification?.name,
          tierOrder: a.team.levelClassification?.tierOrder ?? 0,
        ),
      );
    }

    // Chapters: unique level classifications the athlete has attended,
    // sorted by tier_order ASC.
    final uniqueLevels = <String, _ChapterSeed>{};
    for (final info in teamInfo.values) {
      uniqueLevels.putIfAbsent(
        info.levelId,
        () => _ChapterSeed(info.levelId, info.tierOrder),
      );
    }
    final sortedLevels = uniqueLevels.values.toList()
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));
    final chapters = <_Chapter>[
      for (var i = 0; i < sortedLevels.length; i++)
        _Chapter(index: i, levelId: sortedLevels[i].levelId),
    ];

    // Level index map for team ordering.
    final levelIndex = <String, int>{
      for (final c in chapters) c.levelId: c.index,
    };

    // Teams in display order: sort by their chapter's index ASC,
    // then within a chapter by most-recent assessment DESC.
    DateTime latestFor(_TeamInfo t) {
      final ass = byTeam[t.teamId] ?? const [];
      if (ass.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.parse(ass.first.submittedAt);
    }
    final teams = teamInfo.values.toList()
      ..sort((a, b) {
        final ai = levelIndex[a.levelId] ?? 0;
        final bi = levelIndex[b.levelId] ?? 0;
        if (ai != bi) return ai.compareTo(bi);
        return latestFor(b).compareTo(latestFor(a));
      });
    final teamsInDisplayOrder = <_TeamGroup>[
      for (final t in teams)
        _TeamGroup(
          teamId: t.teamId,
          teamName: t.teamName,
          ageGroup: t.ageGroup,
          levelClassificationId: t.levelId,
          levelName: t.levelName,
          assessments: byTeam[t.teamId] ?? const [],
        ),
    ];

    return _Derived(chapters: chapters, teamsInDisplayOrder: teamsInDisplayOrder);
  }
}

class _TeamInfo {
  const _TeamInfo({
    required this.teamId,
    required this.teamName,
    required this.ageGroup,
    required this.levelId,
    required this.levelName,
    required this.tierOrder,
  });
  final String teamId;
  final String teamName;
  final String? ageGroup;
  final String levelId;
  final String? levelName;
  final int tierOrder;
}

class _ChapterSeed {
  const _ChapterSeed(this.levelId, this.tierOrder);
  final String levelId;
  final int tierOrder;
}

class _Chapter {
  const _Chapter({required this.index, required this.levelId});
  final int index;
  final String levelId;
}

class _TeamGroup {
  const _TeamGroup({
    required this.teamId,
    required this.teamName,
    required this.ageGroup,
    required this.levelClassificationId,
    required this.levelName,
    required this.assessments,
  });
  final String teamId;
  final String teamName;
  final String? ageGroup;
  final String levelClassificationId;
  final String? levelName;
  final List<Assessment> assessments;
}

class _Derived {
  const _Derived({required this.chapters, required this.teamsInDisplayOrder});
  final List<_Chapter> chapters;
  final List<_TeamGroup> teamsInDisplayOrder;
}
