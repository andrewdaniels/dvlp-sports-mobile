import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_profile.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';

/// Team hero card shown at the top of any Team-scoped page — athlete
/// Team, coach Team, and later coach Home.
///
/// Featured + prominent AppCard with leading avatar (team crest when
/// team.logoUrl lands; initials fallback today), uppercase team name,
/// and composed subtitle. Visually parallels AppProfileHeader but is
/// its own composition because the domain is different (team, not
/// person) and the two should be free to diverge — e.g., a team hero
/// might grow a "roster count" line or a league logo that a person
/// header never needs.
///
/// Subtitle composition owned here so callers don't duplicate the
/// `[age, level].join(' · ')` on every page. League is a future slot
/// — currently returns "U13 AAA"; will read "U13 AAA · Northern
/// League" once teams have a league column.
class TeamHeader extends StatelessWidget {
  const TeamHeader({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = _composeSubtitle(team);

    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Team crest slot. No image URL on the team model yet — falls
          // back to initials of the club name. Wire imageUrl when we
          // add teams.logo_url.
          AppAvatar(
            firstName: team.name,
            size: AppAvatarSize.large,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  team.name.toUpperCase(),
                  style: AppTypography.anybody(fontSize: 24, color: colors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(color: colors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _composeSubtitle(Team team) {
    final parts = <String>[
      if ((team.ageGroup ?? '').trim().isNotEmpty) team.ageGroup!.trim(),
      if ((team.levelClassification ?? '').trim().isNotEmpty) team.levelClassification!.trim(),
    ];
    return parts.join(' · ');
  }
}
