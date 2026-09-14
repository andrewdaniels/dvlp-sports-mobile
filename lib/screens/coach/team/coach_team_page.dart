import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/team/controllers/games_providers.dart';
import '../../../features/team/controllers/team_roster_providers.dart';
import '../../../features/team/ui/widgets/coach_athlete_passport_card.dart';
import '../../../features/team/ui/widgets/external_connection_row.dart';
import '../../../features/team/ui/widgets/roster_row.dart';
import '../../../features/team/ui/widgets/stat_card.dart';
import '../../../features/team/ui/widgets/team_header.dart';
import '../../../generated/api/get_games.dart';
import '../../../generated/api/get_profile.dart' as profile_api;
import '../../../generated/api/get_team_roster.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';

/// Coach Team tab.
///   - Hero: TeamHeader (team crest + name + subtitle).
///   - Stats row: RECORD (from games) + RANKING (placeholder '-'
///     until we have a standings source).
///   - Roster: RosterRows from get-team-roster, each with the
///     athlete's ranking coin at their team's level.
///   - External Connections: deferred (needs a backend endpoint —
///     tracked as follow-up).
///
/// Coach's active team resolves from currentProfileProvider's first
/// coach-scope team_membership (same lookup as CoachGamesPage). Multi-
/// team switcher lands with the multi-team coach flow.
class CoachTeamPage extends ConsumerWidget {
  const CoachTeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          final coachMembership = profile.teamMemberships
              .where((m) => m.coachType != null)
              .firstOrNull;
          if (coachMembership == null) {
            return const _EmptyNoTeam();
          }
          return _CoachTeamBody(team: coachMembership.team);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _CoachTeamBody extends ConsumerWidget {
  const _CoachTeamBody({required this.team});

  final profile_api.Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider(team.id));
    final rosterAsync = ref.watch(teamRosterProvider(team.id));

    final games = gamesAsync.value?.games ?? const <Game>[];
    final roster = rosterAsync.value?.roster ?? const <Roster>[];
    final externals = rosterAsync.value?.externalConnections ?? const <ExternalConnection>[];
    final rosterLoading = rosterAsync.isLoading && roster.isEmpty && externals.isEmpty;

    return AppRefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(gamesProvider(team.id).notifier).refresh(),
          ref.read(teamRosterProvider(team.id).notifier).refresh(),
        ]);
      },
      child: ListView(
        padding: AppPageInsets.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          TeamHeader(team: team),
          const SizedBox(height: AppSpacing.md),
          _StatsRow(games: games),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(label: 'Roster'),
          const SizedBox(height: AppSpacing.sm),
          if (rosterLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: AppLoadingIndicator()),
            )
          else if (roster.isEmpty)
            const _EmptyRoster()
          else
            for (var i = 0; i < roster.length; i++) ...[
              RosterRow(
                entry: roster[i],
                onTap: () => context.push(
                  RouteNames.coachAthleteDetailsFor(roster[i].athlete.id),
                  extra: AthletePassportRanking.fromRoster(
                    codegenBand: roster[i].ranking?.band,
                    subLevel: roster[i].ranking?.subLevel,
                  ),
                ),
              ),
              if (i < roster.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          if (externals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(label: 'External Connections'),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < externals.length; i++) ...[
              ExternalConnectionRow(
                entry: externals[i],
                onTap: () => context.push(
                  RouteNames.coachAthleteDetailsFor(externals[i].athlete.id),
                  extra: AthletePassportRanking.fromRoster(
                    codegenBand: externals[i].ranking?.band,
                    subLevel: externals[i].ranking?.subLevel,
                  ),
                ),
              ),
              if (i < externals.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.games});
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final record = _computeRecord(games);
    return Row(
      children: [
        Expanded(child: StatCard(label: 'RECORD', value: record)),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: StatCard(label: 'RANKING', value: '-', accent: true)),
      ],
    );
  }

  static String _computeRecord(List<Game> games) {
    var w = 0, l = 0, t = 0;
    for (final g in games) {
      final ts = g.teamScore, os = g.opponentScore;
      if (ts == null || os == null) continue;
      if (ts > os) {
        w++;
      } else if (ts < os) {
        l++;
      } else {
        t++;
      }
    }
    return '$w-$l-$t';
  }
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
          'No team yet.\nYour roster will appear once you\'re added to a team.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          'No athletes on this team yet.',
          style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
