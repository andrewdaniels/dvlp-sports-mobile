import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_team_roster.dart' as roster;
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_level_badge.dart';

/// One row on the coach Team page's Roster section.
///
///   ┌──────────────────────────────────────────────────┐
///   │ (avatar)  Name                          (coin)   │
///   │           Position · Silver I                     │
///   └──────────────────────────────────────────────────┘
///
/// Consumes one roster entry from the get-team-roster response —
/// nested `athlete` + `ranking?` shape (codegen names the entry
/// class `Roster` because it's the item type of the `roster: [...]`
/// array). When `ranking` is null (athlete has no summary at this
/// team's level yet), the coin slot renders empty and the subtitle
/// drops the band label.
///
/// Fires a light haptic + forwards `onTap` (Player Details route
/// wires on a follow-up branch).
class RosterRow extends StatelessWidget {
  const RosterRow({
    super.key,
    required this.entry,
    this.onTap,
  });

  final roster.Roster entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final r = entry.ranking;
    final band = r == null ? null : _mapBand(r.band);
    final subtitle = _composeSubtitle(a.position?.name, band, r?.subLevel);

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
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
              // Preserve horizontal layout when unranked — same width as
              // the coin so name+subtitle don't shift between rows.
              // Dart const-eval can't read enum instance fields, so the
              // 32 is inlined; kept in sync with AppLevelCoinSize.small.
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

  /// "Forward · Silver I", "Forward", or "" — position + band label,
  /// dot-separated. Drops either side gracefully when missing.
  static String _composeSubtitle(String? position, LevelBand? band, int? subLevel) {
    final parts = <String>[
      if ((position ?? '').isNotEmpty) position!,
      if (band != null && subLevel != null) '${band.displayName} ${_roman(subLevel)}',
    ];
    return parts.join(' · ');
  }

  static String _roman(int n) => switch (n) {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        _ => n.toString(),
      };

  // Stopgap mapper between the codegen `Band` enum (uppercase, sourced
  // from Zod) and the theme's `LevelBand` (lowercase, owns brand color
  // + display name + coin asset paths). Deleted when the shared-schemas
  // codegen redesign (Path A follow-up) unifies these.
  static LevelBand _mapBand(roster.Band b) => switch (b) {
        roster.Band.BEGINNER => LevelBand.beginner,
        roster.Band.BRONZE => LevelBand.bronze,
        roster.Band.SILVER => LevelBand.silver,
        roster.Band.GOLD => LevelBand.gold,
        roster.Band.ELITE => LevelBand.elite,
      };
}
