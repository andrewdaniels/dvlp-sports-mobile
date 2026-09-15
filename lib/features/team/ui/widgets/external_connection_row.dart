import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_team_roster.dart' as roster;
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_level_badge.dart';

/// One row in the coach Team page's "External Connections" section —
/// an athlete the current coach has an active external grant for.
///
///   ┌──────────────────────────────────────────────────────────┐
///   │ (avatar)  Name                                     (coin) │
///   │           Position · Markham Majors U12 AA           (›)  │
///   └──────────────────────────────────────────────────────────┘
///
/// Distinct from `RosterRow` because:
///   - Subtitle contains the athlete's CURRENT team name (not just
///     position), rendered in the `link` blue to differentiate the
///     external context from own-team roster styling. Tap is not
///     wired on the team name — the whole row taps through to the
///     Player Details route (wire on follow-up).
///   - Coin reflects ranking at the ATHLETE's current team level
///     (see docs/scoring.md), not the coach's team level.
///   - `current_team` can be null (athlete left every team but the
///     grant is still active) — renders "-" for team + empty coin.
///
/// Codegen names to note: quicktype named the position type
/// `PurplePosition` (it names shape-identical types differently
/// per parent). Tracked as the shared-schemas codegen follow-up.
class ExternalConnectionRow extends StatelessWidget {
  const ExternalConnectionRow({
    super.key,
    required this.entry,
    this.onTap,
  });

  final roster.ExternalConnection entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final r = entry.ranking;
    final band = r == null ? null : _mapBand(r.band);
    final teamLabel = _teamLabel(entry.currentTeam);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppAvatar(
              imageUrl: a.avatarUrl,
              firstName: a.firstName,
              lastName: a.lastName,
              size: AppAvatarSize.small,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_initial(a.firstName)}. ${a.lastName}',
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _Subtitle(
                    position: a.position?.name,
                    teamLabel: teamLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (band != null && r != null)
              AppLevelCoin(
                band: band,
                subLevel: r.subLevel,
                size: AppLevelCoinSize.small,
              )
            else
              // Preserve horizontal layout when unranked. Matches
              // AppLevelCoinSize.small; kept inline for const-eval.
              const SizedBox(width: 32),
            const SizedBox(width: AppSpacing.sm),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  /// "M. Thompson" — first initial + last name, matching the Figma.
  static String _initial(String firstName) {
    final trimmed = firstName.trim();
    return trimmed.isEmpty ? '' : trimmed[0].toUpperCase();
  }

  /// "Markham Majors U12 AA" or "-" — composes the athlete's current
  /// team display from name + age + level. Returns "-" when the
  /// athlete has no active team.
  static String _teamLabel(roster.CurrentTeam? team) {
    if (team == null) return '-';
    final parts = <String>[
      team.name,
      (team.ageGroup ?? '').trim(),
      (team.levelClassification ?? '').trim(),
    ].where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  // Stopgap mapper between codegen Band enum (uppercase) and theme's
  // LevelBand (lowercase). Deleted when shared-schemas codegen lands.
  static LevelBand _mapBand(roster.Band b) => switch (b) {
        roster.Band.BEGINNER => LevelBand.beginner,
        roster.Band.BRONZE => LevelBand.bronze,
        roster.Band.SILVER => LevelBand.silver,
        roster.Band.GOLD => LevelBand.gold,
        roster.Band.ELITE => LevelBand.elite,
      };
}

/// Subtitle inline layout: `Position · <team name in blue>`. Uses a
/// RichText so the team-name segment can render in `link` color
/// without adding a tap gesture. Whole row's onTap owns navigation.
class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.position, required this.teamLabel});

  final String? position;
  final String teamLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPos = (position ?? '').isNotEmpty;
    final positionStyle = AppTypography.labelSmall.copyWith(color: colors.secondaryText);
    final teamStyle = AppTypography.labelSmall.copyWith(color: colors.link);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (hasPos) ...[
            TextSpan(text: position, style: positionStyle),
            TextSpan(text: ' · ', style: positionStyle),
          ],
          TextSpan(text: teamLabel, style: teamStyle),
        ],
      ),
    );
  }
}
