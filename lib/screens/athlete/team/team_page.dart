import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/team/controllers/games_providers.dart';
import '../../../generated/api/get_games.dart';
import '../../../generated/api/get_profile.dart' as profile_api;
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_divider.dart';
import '../../../shared/widgets/app_profile_header.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_text_badge.dart';

class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.teamMemberships.isEmpty) {
            return const SizedBox.shrink();
          }
          return _TeamBody(team: profile.teamMemberships.first.team);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _TeamBody extends ConsumerWidget {
  const _TeamBody({required this.team});

  final profile_api.Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider(team.id));
    final games = gamesAsync.value?.games ?? const <Game>[];

    final recap = _RecapCard.lastPlayed(games);

    return AppRefreshIndicator(
      onRefresh: () => ref.read(gamesProvider(team.id).notifier).refresh(),
      child: ListView(
        padding: AppPageInsets.padding,
        children: [
          _TeamHeader(team: team),
          const SizedBox(height: AppSpacing.md),
          _StatsRow(games: games),
          const SizedBox(height: AppSpacing.md),
          _NextGameCard(games: games),
          if (recap != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Last Game Recap',
              style: AppTypography.titleMedium.copyWith(color: context.colors.primaryText),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RecapCard(recap: recap),
          ],
        ],
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.team});
  final profile_api.Team team;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if ((team.levelClassification ?? '').isNotEmpty) team.levelClassification!,
      // Northern League etc. isn't in the schema yet — placeholder slot
      // for when it is. Keeping the join here so we can drop the value
      // in without touching call sites.
    ];
    return AppProfileHeader(
      title: team.name,
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.games});
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final record = _computeRecord(games);
    // Ranking isn't in the schema yet — placeholder until we have a
    // standings source.
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'RECORD', value: record)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _StatCard(label: 'RANKING', value: '-')),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRanking = label == 'RANKING';
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.boldSmall.copyWith(
              color: colors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: isRanking ? colors.secondary : colors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextGameCard extends StatelessWidget {
  const _NextGameCard({required this.games});
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final next = _nextGame(games);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT GAME',
            style: AppTypography.boldSmall.copyWith(
              color: colors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            next == null ? '-' : 'vs ${next.opponentName}',
            style: AppTypography.titleLarge.copyWith(color: colors.primaryText),
          ),
          if (next != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatNextGameLine(next),
              style: AppTypography.boldMedium.copyWith(color: colors.link),
            ),
          ],
        ],
      ),
    );
  }

  static Game? _nextGame(List<Game> games) {
    final now = DateTime.now();
    final upcoming = games.where((g) {
      final scheduledOnly = g.teamScore == null && g.opponentScore == null;
      if (!scheduledOnly) return false;
      final at = DateTime.tryParse(g.startsAt);
      return at != null && at.isAfter(now);
    }).toList()
      ..sort((a, b) => DateTime.parse(a.startsAt).compareTo(DateTime.parse(b.startsAt)));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  static String _formatNextGameLine(Game g) {
    final at = DateTime.tryParse(g.startsAt);
    final parts = <String>[];
    if (at != null) parts.add(_formatWeekdayTime(at.toLocal()));
    if ((g.location ?? '').isNotEmpty) parts.add(g.location!);
    return parts.join(' · ');
  }
}

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _monthAbbr = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// "Saturday, 10:15 AM"
String _formatWeekdayTime(DateTime dt) {
  final weekday = _weekdayNames[dt.weekday - 1];
  final hour24 = dt.hour;
  final ampm = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$weekday, $hour12:$mm $ampm';
}

/// "FEB 22"
String _formatShortDate(DateTime dt) => '${_monthAbbr[dt.month - 1]} ${dt.day}';

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.recap});
  final Game recap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ts = recap.teamScore!;
    final os = recap.opponentScore!;
    final (label, badgeColor) = _resultBadge(context, ts, os);
    final metaLine = _formatMetaLine(recap);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$ts-$os',
                style: AppTypography.headlineSmall.copyWith(color: colors.primaryText),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppTextBadge(label: label, color: badgeColor, size: AppTextBadgeSize.medium),
              const Spacer(),
              Text(
                metaLine,
                style: AppTypography.boldSmall.copyWith(
                  color: colors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if ((recap.note ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const AppDivider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              '“${recap.note!}”',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
            // TODO: swap "Coach" for the real coach name once we can
            // resolve note_coach_id → profile locally.
            const SizedBox(height: AppSpacing.xs),
            Text(
              '- Coach',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondary),
            ),
          ],
        ],
      ),
    );
  }

  /// Games are sorted `starts_at` DESC; first completed is the most recent.
  /// Exposed so the parent can decide to hide the entire section when
  /// there's no recap to show.
  static Game? lastPlayed(List<Game> games) {
    for (final g in games) {
      if (g.teamScore != null && g.opponentScore != null) return g;
    }
    return null;
  }

  static (String, Color) _resultBadge(BuildContext context, int team, int opponent) {
    final colors = context.colors;
    if (team > opponent) return ('Win', colors.success);
    if (team < opponent) return ('Loss', colors.error);
    return ('Tie', colors.link);
  }

  static String _formatMetaLine(Game g) {
    final at = DateTime.tryParse(g.startsAt);
    final parts = <String>['VS ${g.opponentName.toUpperCase()}'];
    if (at != null) parts.add(_formatShortDate(at.toLocal()));
    return parts.join(' · ');
  }
}
