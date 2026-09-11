import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/assessments/controllers/assessments_providers.dart';
import '../../../features/assessments/ui/widgets/app_feedback_list_item.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../generated/api/get_assessments.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_detail_app_bar.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_tab_bar.dart';

/// Full-screen destination pushed from Passport's "See All" link.
/// Shows the athlete's entire submitted-feedback history across
/// every team + level.
///
/// Layout:
///   1. Chapter tabs — one per unique level_classification the athlete
///      has attended, labeled "Chapter N - LEVEL_NAME" (e.g.
///      "Chapter 1 - AAA"). Chapter numbers are per-athlete and
///      index-based: their attended levels sorted by `tier_order` ASC,
///      numbered from 1. An athlete who skipped SingleA sees their
///      lowest attended level as Chapter 1.
///   2. Team chips — inside the selected chapter, one per team the
///      athlete played on at that level. "All" chip clears the team
///      filter within the chapter.
///   3. Flat list — filtered feedback rows using `AppFeedbackListItem`.
///
/// Defaults to the highest / most-recent-tier chapter on first
/// mount so athletes see their current-season feedback first.
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
  /// Selected chapter index. Null until derivation runs; then defaults
  /// to the highest tier (last index).
  int? _chapterIndex;

  /// Selected team.id inside the current chapter, or null for "All"
  /// teams in that chapter. Resets to null when the chapter changes.
  String? _teamId;

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
            chapterIndex: _chapterIndex,
            teamId: _teamId,
            onSelectChapter: (i) => setState(() {
              _chapterIndex = i;
              // Team filter is per-chapter — reset to All when the
              // athlete switches chapters.
              _teamId = null;
            }),
            onSelectTeam: (id) => setState(() => _teamId = id),
          );
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

class _Body extends ConsumerWidget {
  const _Body({
    required this.athleteId,
    required this.chapterIndex,
    required this.teamId,
    required this.onSelectChapter,
    required this.onSelectTeam,
  });

  final String athleteId;
  final int? chapterIndex;
  final String? teamId;
  final ValueChanged<int> onSelectChapter;
  final ValueChanged<String?> onSelectTeam;

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
          chapterIndex: chapterIndex,
          teamId: teamId,
          onSelectChapter: onSelectChapter,
          onSelectTeam: onSelectTeam,
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
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
    required this.chapterIndex,
    required this.teamId,
    required this.onSelectChapter,
    required this.onSelectTeam,
  });

  final List<Assessment> all;
  final int? chapterIndex;
  final String? teamId;
  final ValueChanged<int> onSelectChapter;
  final ValueChanged<String?> onSelectTeam;

  @override
  Widget build(BuildContext context) {
    final derived = _derive(all);
    if (derived.chapters.isEmpty) {
      // Shouldn't happen if `all` is non-empty, but guard defensively.
      return const SizedBox.shrink();
    }

    // Default to the highest tier (last chapter, since chapters are
    // sorted ASC by tier_order). Falls through to a valid index if
    // parent state hasn't set one yet.
    final effectiveChapter = chapterIndex ?? derived.chapters.length - 1;
    final chapter = derived.chapters[effectiveChapter.clamp(0, derived.chapters.length - 1)];

    // Teams within this chapter, sorted by most-recent assessment DESC.
    final teamsInChapter = derived.teamsInDisplayOrder
        .where((t) => t.levelClassificationId == chapter.levelId)
        .toList();

    // Assessments filtered by team selection (or all teams in chapter).
    final visibleAssessments = <Assessment>[];
    for (final t in teamsInChapter) {
      if (teamId != null && t.teamId != teamId) continue;
      visibleAssessments.addAll(t.assessments);
    }
    // Preserve most-recent-first order across teams — assessments
    // arrive already sorted `submitted_at desc`, but concatenating per
    // team can shuffle across boundaries.
    visibleAssessments.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return ListView(
      padding: AppPageInsets.padding,
      children: [
        // ── Chapter tabs ──────────────────────────────────────
        AppTabBar(
          labels: [
            for (final c in derived.chapters) 'Chapter ${c.index + 1} - ${c.levelName ?? ''}'.trim(),
          ],
          currentIndex: effectiveChapter,
          onTap: onSelectChapter,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Team chips (only when this chapter has 2+ teams) ──
        if (teamsInChapter.length > 1) ...[
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AppChip(
                  label: 'All',
                  selected: teamId == null,
                  onTap: () => onSelectTeam(null),
                ),
                for (final t in teamsInChapter) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppChip(
                    label: _chipLabel(t),
                    selected: teamId == t.teamId,
                    onTap: () => onSelectTeam(t.teamId),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Flat feedback list ────────────────────────────────
        for (var i = 0; i < visibleAssessments.length; i++) ...[
          AppFeedbackListItem(
            assessment: visibleAssessments[i],
            unread: !visibleAssessments[i].athleteRead,
            onTap: () {
              final a = visibleAssessments[i];
              final path = a.assessmentType == AssessmentType.QUICK
                  ? RouteNames.feedbackQuickFor(a.id)
                  : RouteNames.feedbackFormalFor(a.id);
              context.push(path);
            },
          ),
          if (i < visibleAssessments.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  /// Compose the chip label from the team's constituent parts:
  /// club identity + age group + level classification.
  /// E.g. name="Rampage" + age="U11" + level="A" → "Rampage U11 A".
  static String _chipLabel(_TeamGroup t) {
    final parts = [
      t.teamName.trim(),
      (t.ageGroup ?? '').trim(),
      (t.levelName ?? '').trim(),
    ].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  // ─── Derivation ─────────────────────────────────────────────
  // Pure projection: input = list of assessments; output = chapters
  // (level groups sorted by tier_order) + teams-in-display-order
  // (grouped by team.id, sorted within a chapter by most-recent
  // assessment).
  static _Derived _derive(List<Assessment> all) {
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
    // sorted by tier_order ASC. Chapter N = the (N-1)th entry in this
    // sorted list. Athletes never see a chapter they haven't played at.
    final uniqueLevels = <String, _ChapterSeed>{};
    for (final info in teamInfo.values) {
      uniqueLevels.putIfAbsent(
        info.levelId,
        () => _ChapterSeed(info.levelId, info.tierOrder, info.levelName),
      );
    }
    final sortedLevels = uniqueLevels.values.toList()
      ..sort((a, b) => a.tierOrder.compareTo(b.tierOrder));
    final chapters = <_Chapter>[
      for (var i = 0; i < sortedLevels.length; i++)
        _Chapter(
          index: i,
          levelId: sortedLevels[i].levelId,
          levelName: sortedLevels[i].levelName,
        ),
    ];

    // Level index map for team ordering.
    final levelIndex = <String, int>{
      for (final c in chapters) c.levelId: c.index,
    };

    // Teams in display order: sort by chapter index ASC, then within
    // a chapter by most-recent assessment DESC.
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
  const _ChapterSeed(this.levelId, this.tierOrder, this.levelName);
  final String levelId;
  final int tierOrder;
  final String? levelName;
}

class _Chapter {
  const _Chapter({required this.index, required this.levelId, required this.levelName});
  final int index;
  final String levelId;
  final String? levelName;
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
