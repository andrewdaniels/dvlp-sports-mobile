import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/team/controllers/games_providers.dart';
import '../../../features/team/ui/widgets/game_result_row.dart';
import '../../../features/team/ui/widgets/todo_row.dart';
import '../../../features/team/ui/widgets/upcoming_game_card.dart';
import '../../../generated/api/get_games.dart';
import '../../../generated/api/get_profile.dart' as profile_api;
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';

/// Coach Games tab. Three sections:
///   - To-Do — post-game reports pending (completed games with no note).
///   - Upcoming — horizontal-scroll list of scheduled future games.
///   - Results — vertical list of completed games with scores.
///
/// All three project the same `get-games` response filtered client-side.
/// Coach team is resolved from the first coach-scope membership on the
/// profile (mirroring [CoachProfilePage]); multi-team switcher lands
/// with the multi-team coach flow.
class CoachGamesPage extends ConsumerWidget {
  const CoachGamesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          final coachMembership = profile.teamMemberships
              .where((m) => m.coachType != null)
              .firstOrNull;
          if (coachMembership == null) {
            return const _EmptyNoTeam();
          }
          return _CoachGamesBody(team: coachMembership.team);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _CoachGamesBody extends ConsumerWidget {
  const _CoachGamesBody({required this.team});

  final profile_api.Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider(team.id));
    final games = gamesAsync.value?.games ?? const <Game>[];

    // Client-side derivations. Games arrive `starts_at` DESC.
    //
    // "Pending post-game report" = the game has already been played
    // and the coach hasn't entered a score yet. Notes are optional
    // (per client spec) so an unmarked note doesn't trigger the
    // to-do. Once scores are set, the report is done regardless of
    // note / standout state.
    final now = DateTime.now();
    final pendingReports = <Game>[];
    final upcoming = <Game>[];
    final results = <Game>[];
    for (final g in games) {
      final scored = g.teamScore != null && g.opponentScore != null;
      if (scored) {
        results.add(g);
        continue;
      }
      final startsAt = DateTime.tryParse(g.startsAt);
      if (startsAt == null) continue;
      if (startsAt.isAfter(now)) {
        upcoming.add(g);
      } else {
        pendingReports.add(g);
      }
    }
    // Upcoming should read ASC (soonest first); games arrive DESC.
    upcoming.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    // Outer ListView takes vertical-only padding. Each section owns
    // its own horizontal gutter — vertical sections wrap in
    // Padding(horizontal: hPad); the horizontal Upcoming scroller
    // uses its own contentInset so cards can bleed to the screen
    // edge on scroll (standard iOS carousel pattern).
    return AppRefreshIndicator(
      onRefresh: () => ref.read(gamesProvider(team.id).notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppPageInsets.top,
          bottom: AppPageInsets.bottom,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (pendingReports.isNotEmpty) ...[
            const _PaddedSection(
              child: _SectionHeader(label: 'To-Do'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PaddedSection(
              child: _PendingReportsSection(games: pendingReports),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (upcoming.isNotEmpty) ...[
            const _PaddedSection(
              child: _SectionHeader(label: 'Upcoming'),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Not wrapped in _PaddedSection — the horizontal scroller
            // owns its own leading/trailing inset so cards can scroll
            // flush to the screen edge.
            _UpcomingScroller(games: upcoming),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (results.isNotEmpty) ...[
            const _PaddedSection(
              child: _SectionHeader(label: 'Results'),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < results.length; i++) ...[
              _PaddedSection(
                child: GameResultRow(
                  game: results[i],
                  onTap: () => context.push(
                    RouteNames.coachGameDetailsFor(results[i].id),
                  ),
                ),
              ),
              if (i < results.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

/// Wraps children that live inside the vertical scroll but need the
/// standard page horizontal gutter. Horizontal scrollers should NOT
/// use this — they apply their own leading/trailing inset via
/// ListView's `padding` prop so cards can bleed to the screen edge.
class _PaddedSection extends StatelessWidget {
  const _PaddedSection({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPageInsets.horizontal,
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
    );
  }
}

/// Renders one TodoRow per pending post-game report. Title is
/// intentionally uncounted ("Post-game report pending") — one row per
/// game reads clearer than aggregation and mirrors what taps will do
/// (each row opens that specific game's report). Subtitle carries the
/// game context so the two rows are visually distinguishable.
class _PendingReportsSection extends StatelessWidget {
  const _PendingReportsSection({required this.games});
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        for (var i = 0; i < games.length; i++) ...[
          TodoRow(
            icon: AppIcons.coachNavGames,
            iconColor: colors.error,
            title: 'Post-game report pending',
            subtitle: _subtitle(games[i]),
            onTap: () => context.push(
              RouteNames.coachGameDetailsFor(games[i].id),
            ),
          ),
          if (i < games.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  static String _subtitle(Game g) {
    final at = DateTime.tryParse(g.startsAt)?.toLocal();
    final opponent = '${g.isHome ? 'vs' : '@'} ${g.opponentName}';
    if (at == null) return opponent;
    return '$opponent · ${_shortDate(at)}';
  }

  static String _shortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _UpcomingScroller extends StatelessWidget {
  const _UpcomingScroller({required this.games});
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      // Horizontal contentInset gives the first/last cards the same
      // gutter as vertical sections; scroll extends beyond that inset
      // so cards visually flow to the screen edge on scroll.
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppPageInsets.horizontal,
        ),
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => UpcomingGameCard(
          game: games[i],
          onTap: () => context.push(
            RouteNames.coachGameDetailsFor(games[i].id),
          ),
        ),
      ),
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
          'No team yet.\nGames will appear once you\'re added to a team.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
