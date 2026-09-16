import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/coach_feedback/controllers/coach_feedback_providers.dart';
import '../../../features/home/controllers/coach_home_providers.dart';
import '../../../features/home/ui/widgets/skill_average_row.dart';
import '../../../features/home/ui/widgets/team_health_hero_card.dart';
import '../../../features/notifications/controllers/notifications_providers.dart';
import '../../../features/team/controllers/games_providers.dart';
import '../../../features/team/ui/widgets/todo_row.dart';
import '../../../generated/api/get_games.dart';
import '../../../generated/api/get_profile.dart' as profile_api;
import '../../../generated/api/get_team_aggregates.dart' as agg_api;
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/app_indicator_badge.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';

/// Coach home landing.
///
/// Sections:
///   1. Team Health hero — team crest + name + subtitle + avg tier +
///      X/Y evaluated. Avg tier from teamAggregatesProvider; X/Y from
///      the same coachFeedbackSummaryProvider the Feedback tab uses.
///   2. To-Do — pending formals + pending post-game reports + pending
///      quick feedback requests. Each row taps into the appropriate
///      tab so the coach can drill in.
///   3. Team Skill Levels — per-skill averages from
///      teamAggregatesProvider, rendered with SkillAverageRow.
///
/// Composes from existing providers where possible; only new fetch is
/// the aggregates endpoint. Mutations across the app (composer create/
/// update) invalidate aggregates + summary, so numbers stay fresh
/// without extra plumbing.
class CoachHomePage extends ConsumerWidget {
  const CoachHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          AppIndicatorBadge(
            show: unreadCount > 0,
            count: unreadCount,
            child: AppIconButton(
              icon: AppIcons.bell,
              size: AppIconButtonSize.large,
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(RouteNames.notifications);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          final coachMembership = profile.teamMemberships
              .where((m) => m.coachType != null)
              .firstOrNull;
          if (coachMembership == null) return const _EmptyNoTeam();
          return _Body(team: coachMembership.team);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.team});
  final profile_api.Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(coachFeedbackSummaryProvider);
    final gamesAsync = ref.watch(gamesProvider(team.id));
    final aggAsync = ref.watch(teamAggregatesProvider(team.id));

    final summary = summaryAsync.value;
    final games = gamesAsync.value?.games ?? const <Game>[];
    final agg = aggAsync.value;

    final pendingFormals = summary?.formalCadence.pendingAthletes ?? const [];
    final pendingRequests = summary?.quickFeedbackRequests ?? const [];
    final pendingReports = _pendingReports(games);
    final teamSubtitle = _composeTeamSubtitle(team);

    return AppRefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(coachFeedbackSummaryProvider.notifier).refresh(),
          ref.read(gamesProvider(team.id).notifier).refresh(),
          ref.read(teamAggregatesProvider(team.id).notifier).refresh(),
          // Bell dot on this page reflects notification freshness; if
          // the coach is on Home, refresh the inbox too so
          // pull-to-refresh here Just Works for the badge.
          ref.read(notificationsProvider.notifier).refresh(),
        ]);
      },
      child: ListView(
        padding: AppPageInsets.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          TeamHealthHeroCard(
            teamName: team.name,
            teamSubtitle: teamSubtitle,
            avgBand: agg?.avgTier == null ? null : _mapBand(agg!.avgTier!.band),
            avgSubLevel: agg?.avgTier?.subLevel,
            completedCount: summary?.formalCadence.completedCount ?? 0,
            totalAthletes: summary?.formalCadence.totalAthletes ?? 0,
          ),
          const SizedBox(height: AppSpacing.xl),

          if (pendingFormals.isNotEmpty ||
              pendingReports.isNotEmpty ||
              pendingRequests.isNotEmpty) ...[
            _SectionHeader(label: 'To-Do'),
            const SizedBox(height: AppSpacing.sm),
            if (pendingFormals.isNotEmpty) ...[
              TodoRow(
                icon: AppIcons.star,
                iconColor: context.colors.error,
                title: '${pendingFormals.length} Formal Assessment${pendingFormals.length == 1 ? '' : 's'} due',
                subtitle: _athleteNamesSubtitle(
                  pendingFormals.map((p) => (p.athlete.firstName, p.athlete.lastName)),
                ),
                onTap: () => context.go(RouteNames.coachFeedback),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (pendingReports.isNotEmpty) ...[
              TodoRow(
                icon: AppIcons.coachNavGames,
                iconColor: context.colors.error,
                title: '${pendingReports.length} Post-Game Report${pendingReports.length == 1 ? '' : 's'}',
                subtitle: _postGameSubtitle(pendingReports.first),
                onTap: () => context.go(RouteNames.coachGames),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (pendingRequests.isNotEmpty) ...[
              TodoRow(
                icon: AppIcons.coachNavFeedback,
                iconColor: context.colors.secondary,
                title: '${pendingRequests.length} Quick Feedback Request${pendingRequests.length == 1 ? '' : 's'}',
                subtitle: _athleteNamesSubtitle(
                  pendingRequests.map((r) => (r.athlete.firstName, r.athlete.lastName)),
                ),
                onTap: () => context.go(RouteNames.coachFeedback),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],

          _SectionHeader(label: 'Team Skill Levels'),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Averages across all players',
            style: AppTypography.labelSmall.copyWith(color: context.colors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          if (aggAsync.isLoading && agg == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: AppLoadingIndicator()),
            )
          else if (agg == null || agg.skillAverages.isEmpty)
            _EmptyText(text: 'No skills yet for this sport.')
          else
            for (var i = 0; i < agg.skillAverages.length; i++) ...[
              SkillAverageRow(
                skillName: agg.skillAverages[i].name,
                avgScore: agg.skillAverages[i].avgScore?.toDouble(),
                // AppScoreBar needs a max. Formal score scale isn't
                // returned by aggregates today, so we assume the
                // sport's max of 10 (matches Hockey). Wire through
                // composerSchemaProvider(teamId).score_scale.max when
                // we support a sport with a different scale.
                maxScore: 10,
              ),
              if (i < agg.skillAverages.length - 1)
                const SizedBox(height: AppSpacing.lg),
            ],
        ],
      ),
    );
  }

  static List<Game> _pendingReports(List<Game> games) {
    // Matches the coach Games page rule: a game that started in the
    // past AND doesn't yet have both scores set is pending. Notes
    // are optional (per client spec) so an empty note alone doesn't
    // count as pending.
    final now = DateTime.now();
    return games.where((g) {
      final scored = g.teamScore != null && g.opponentScore != null;
      if (scored) return false;
      final startsAt = DateTime.tryParse(g.startsAt);
      return startsAt != null && !startsAt.isAfter(now);
    }).toList();
  }

  static String _composeTeamSubtitle(profile_api.Team team) {
    final parts = <String>[
      if ((team.ageGroup ?? '').trim().isNotEmpty) team.ageGroup!.trim(),
      if ((team.levelClassification ?? '').trim().isNotEmpty)
        team.levelClassification!.trim(),
    ];
    return parts.join(' · ');
  }

  /// Design shows first-name + last-initial ("Timmy R., Blake W.") —
  /// diverges from our elsewhere "T. Reyes" pattern but matches the
  /// home mockup exactly. Comma-separated; capped at 3 names to keep
  /// the row's subtitle short (surplus rolls into a "+N more" suffix).
  static String _athleteNamesSubtitle(Iterable<(String, String)> names) {
    const cap = 3;
    final formatted = <String>[];
    var extra = 0;
    for (final (first, last) in names) {
      if (formatted.length < cap) {
        formatted.add(_firstAndLastInitial(first, last));
      } else {
        extra++;
      }
    }
    final base = formatted.join(', ');
    return extra == 0 ? base : '$base +$extra more';
  }

  static String _firstAndLastInitial(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f ${l[0].toUpperCase()}.';
  }

  static String _postGameSubtitle(Game g) {
    final at = DateTime.tryParse(g.startsAt)?.toLocal();
    final dateStr = at == null ? '' : _shortDate(at);
    final vs = 'vs ${g.opponentName}';
    return dateStr.isEmpty ? vs : '$vs · $dateStr';
  }

  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _shortDate(DateTime dt) => '${_monthAbbrev[dt.month - 1]} ${dt.day}';

  /// Codegen names the Band enum by function; map into the theme's
  /// LevelBand so the widgets (which speak LevelBand) work. Same
  /// stopgap the roster row uses — collapsed when Path A codegen
  /// canonicalizes shared enums.
  static LevelBand _mapBand(agg_api.Band b) => switch (b) {
        agg_api.Band.BEGINNER => LevelBand.beginner,
        agg_api.Band.BRONZE => LevelBand.bronze,
        agg_api.Band.SILVER => LevelBand.silver,
        agg_api.Band.GOLD => LevelBand.gold,
        agg_api.Band.ELITE => LevelBand.elite,
      };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(color: context.colors.primaryText),
    );
  }
}

class _EmptyNoTeam extends StatelessWidget {
  const _EmptyNoTeam();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: AppPageInsets.padding,
      child: Center(
        child: Text(
          "No team yet.\nYour Home will fill in once you're added to a team.",
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText),
      ),
    );
  }
}
