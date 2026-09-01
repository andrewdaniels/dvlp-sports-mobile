import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_icon_indicator.dart';

/// List row for a feedback / assessment item.
///
/// Layout (top to bottom):
/// - Row 1: avatar · coach name + role stack · time-ago
/// - Row 2: small icon indicator · optional "NEW" tag · body text · chevron
///
/// Primitive props (no domain model). The feature layer that owns the data
/// passes the right values in. When `unread: true`, the surrounding card
/// gets the `unread` (blue link border) variant AND a "NEW" tag prefixes
/// the body.
///
/// Fires light haptic on tap.
class AppFeedbackListItem extends StatelessWidget {
  const AppFeedbackListItem({
    super.key,
    required this.coachName,
    required this.coachRole,
    required this.timeAgo,
    required this.indicatorIcon,
    required this.indicatorColor,
    required this.body,
    this.coachAvatarUrl,
    this.unread = false,
    this.onTap,
  });

  final String coachName;
  final String coachRole;
  final String timeAgo;
  final String indicatorIcon;
  final Color indicatorColor;
  final String body;
  final String? coachAvatarUrl;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        variant: unread ? AppCardVariant.unread : AppCardVariant.plain,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: avatar + [ (name + time) / role ]
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppAvatar(
                  imageUrl: coachAvatarUrl,
                  firstName: _firstWord(coachName),
                  lastName: _lastWord(coachName),
                  size: AppAvatarSize.small,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              coachName,
                              style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            timeAgo,
                            style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        coachRole,
                        style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Row 2: indicator + optional NEW + body + chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIconIndicator(
                  icon: indicatorIcon,
                  color: indicatorColor,
                  size: AppIconIndicatorSize.small,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        if (unread)
                          TextSpan(
                            text: 'NEW ',
                            style: AppTypography.boldMedium.copyWith(color: colors.link),
                          ),
                        TextSpan(
                          text: body,
                          style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const AppChevronRight(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _firstWord(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : null;
  }

  String? _lastWord(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.last : null;
  }
}
