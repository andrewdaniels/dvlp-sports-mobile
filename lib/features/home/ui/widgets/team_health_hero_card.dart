import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_divider.dart';
import '../../../../shared/widgets/app_level_badge.dart';

/// Coach Home hero — team crest + name + subtitle at top, then two
/// stat tiles inside the same featured card ("Current team health").
///
/// Visually parallels [TeamHeader] on the coach Team page for the top
/// row (crest + name + subtitle) but grows more content below, so this
/// composes directly rather than extending TeamHeader with slots.
///
/// [avgTier] renders the small ranking coin + tier label ("Silver I"
/// etc.); when null (no roster athlete has a submitted formal yet),
/// the tile falls back to a "-" placeholder so the layout stays stable.
///
/// [totalAthletes] / [completedCount] come from the coach feedback
/// summary — same values the Feedback tab hero displays, so both
/// screens stay in sync.
class TeamHealthHeroCard extends StatelessWidget {
  const TeamHealthHeroCard({
    super.key,
    required this.teamName,
    required this.teamSubtitle,
    required this.avgBand,
    required this.avgSubLevel,
    required this.completedCount,
    required this.totalAthletes,
  });

  final String teamName;
  final String teamSubtitle;

  /// Team-level average tier from get-team-aggregates. Null when no
  /// roster athlete has a scored assessment_summary yet.
  final LevelBand? avgBand;
  final int? avgSubLevel;

  final int completedCount;
  final int totalAthletes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Crest slot — no teams.logo_url yet, initials fallback.
              // Swap in imageUrl when we add that column.
              AppAvatar(
                firstName: teamName,
                size: AppAvatarSize.large,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      teamName.toUpperCase(),
                      style: AppTypography.anybody(
                        fontSize: 24,
                        color: colors.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (teamSubtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        teamSubtitle,
                        style: AppTypography.bodySmall.copyWith(color: colors.secondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Label + divider inline: the divider fills the remaining
          // width to the card's right padding rather than stacking
          // full-width below the label.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Current team health',
                style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: AppDivider()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _HealthTile(
                  value: avgBand == null || avgSubLevel == null
                      ? const _TierValuePlaceholder()
                      : _TierValue(band: avgBand!, subLevel: avgSubLevel!),
                  label: 'Avg player Tier',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HealthTile(
                  value: Text(
                    '$completedCount/$totalAthletes',
                    style: AppTypography.headlineSmall.copyWith(color: colors.primaryText),
                  ),
                  label: 'players evaluated',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Plain (non-featured) tile — inset inside the hero. Uses the base
/// AppCard so the fill matches the rest of the app's card language.
class _HealthTile extends StatelessWidget {
  const _HealthTile({required this.value, required this.label});

  final Widget value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 32, child: Center(child: value)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Coin + tier label ("Silver I"), inline. Coin sizing matches the
/// small variant used on the coach passport ranking badge.
class _TierValue extends StatelessWidget {
  const _TierValue({required this.band, required this.subLevel});
  final LevelBand band;
  final int subLevel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLevelCoin(band: band, subLevel: subLevel, size: AppLevelCoinSize.xsmall),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${band.displayName} ${_roman(subLevel)}',
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
      ],
    );
  }

  static String _roman(int n) => switch (n) {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        _ => n.toString(),
      };
}

class _TierValuePlaceholder extends StatelessWidget {
  const _TierValuePlaceholder();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      '-',
      style: AppTypography.titleMedium.copyWith(color: colors.secondaryText),
    );
  }
}
