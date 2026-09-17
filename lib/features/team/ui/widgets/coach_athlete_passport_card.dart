import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/util/profile_format.dart';
import '../../../../generated/api/get_profile.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_level_badge.dart';

/// Passport card for the coach-facing Athlete Details page.
///
/// Visually parallels [AppPlayerPassportCard] but composes `AppCard`
/// directly because the layout differs:
///   - No overlapping hero badge above the card (athlete self-view uses
///     the badge; coach view puts ranking inline via a trailing coin).
///   - Header row has a trailing bordered container with `AppLevelCoin`
///     (medium) + band label ("SILVER I") stacked, right-aligned.
///
/// Same two-section chrome as the athlete passport (tinted header row
/// over solid stats row) so the visual language matches — coach and
/// athlete see the same "passport" vocabulary, just with the ranking
/// surfaced differently based on who's looking.
///
/// Model-aware: consumes [GetProfileData] + an optional [ranking]
/// passed separately (the ranking comes from the roster / external-
/// connection row the caller navigated in with, so we don't have to
/// refetch it). When [ranking] is null, the trailing container is
/// hidden and the header row uses the full width for name + team-line.
///
/// [teamLine] is composed at the call site since it depends on the
/// roster-vs-external context (own team vs. athlete's current team).
class CoachAthletePassportCard extends StatelessWidget {
  const CoachAthletePassportCard({
    super.key,
    required this.profile,
    required this.teamLine,
    this.ranking,
  });

  final GetProfileData profile;
  final String teamLine;
  final AthletePassportRanking? ranking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final athlete = profile.athleteDetails;
    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      // Zero padding on the card so the bottom stats container can
      // go edge-to-edge inside the featured border. Header row owns
      // its own padding.
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderRow(
            firstName: profile.firstName,
            lastName: profile.lastName,
            avatarUrl: profile.avatarUrl,
            teamLine: teamLine,
            ranking: ranking,
          ),
          // Bottom stats section spans the full width of the card.
          // Radius matches AppCard(featured, prominent) → AppRadius.xxl
          // so the corners line up with the card's border.
          Container(
            decoration: BoxDecoration(
              color: colors.alternate,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: _StatsRow(
              age: formatAge(profile.dateOfBirth),
              height: formatHeight(athlete?.heightCm),
              weight: formatWeight(athlete?.weightKg),
              hand: formatDominantSide(athlete?.dominantSide),
              // Verified coach count is not wired yet on either side.
              // Placeholder mirrors the athlete's own passport treatment.
              verified: '-',
            ),
          ),
        ],
      ),
    );
  }
}

/// Ranking surfaced on the passport card — always the (band, sub_level)
/// tuple the caller already has from the roster row. Keeping it small
/// so callers don't need to import codegen types.
class AthletePassportRanking {
  const AthletePassportRanking({required this.band, required this.subLevel});
  final LevelBand band;
  final int subLevel;

  /// Convenience factory that maps the codegen `Band` enum (uppercase,
  /// from get-team-roster) into the theme's `LevelBand` (lowercase, the
  /// enum AppLevelCoin + brand colors read from). Stopgap while the
  /// two enums still exist — Path A codegen refactor collapses them.
  static AthletePassportRanking? fromRoster({
    required Object? codegenBand,
    required int? subLevel,
  }) {
    if (codegenBand == null || subLevel == null) return null;
    final band = switch (codegenBand.toString().split('.').last) {
      'BEGINNER' => LevelBand.beginner,
      'BRONZE' => LevelBand.bronze,
      'SILVER' => LevelBand.silver,
      'GOLD' => LevelBand.gold,
      'ELITE' => LevelBand.elite,
      _ => null,
    };
    if (band == null) return null;
    return AthletePassportRanking(band: band, subLevel: subLevel);
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.teamLine,
    required this.ranking,
  });

  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String teamLine;
  final AthletePassportRanking? ranking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = _formatDisplayName(firstName, lastName);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            firstName: firstName,
            lastName: lastName,
            size: AppAvatarSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  teamLine,
                  style: AppTypography.boldSmall.copyWith(color: colors.secondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (ranking != null) ...[
            const SizedBox(width: AppSpacing.md),
            _RankingBadge(ranking: ranking!),
          ],
        ],
      ),
    );
  }

  static String _formatDisplayName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }
}

/// Trailing bordered container that holds the coin + band label.
/// Uses `secondary` (gold) border to signal it's the marquee stat on
/// this card, matching the styling of the RANKING StatCard on the
/// Team page.
class _RankingBadge extends StatelessWidget {
  const _RankingBadge({required this.ranking});

  final AthletePassportRanking ranking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = '${ranking.band.displayName.toUpperCase()} ${_roman(ranking.subLevel)}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.alternate, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLevelCoin(
            band: ranking.band,
            subLevel: ranking.subLevel,
            size: AppLevelCoinSize.small,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.captionSemibold.copyWith(
              color: colors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  static String _roman(int n) => switch (n) {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        _ => n.toString(),
      };
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.age,
    required this.height,
    required this.weight,
    required this.hand,
    required this.verified,
  });

  final String age;
  final String height;
  final String weight;
  final String hand;
  final String verified;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('AGE', age),
      ('HEIGHT', height),
      ('WEIGHT', weight),
      ('SHOT', hand),
      ('VERIFIED', verified),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Expanded(child: _StatCell(label: e.$1, value: e.$2)),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.captionSemibold.copyWith(
            color: colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
        ),
      ],
    );
  }
}
