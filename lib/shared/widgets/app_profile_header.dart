import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_avatar.dart';
import 'app_card.dart';

/// Page-header card for a person's identity — avatar on the left, title
/// over subtitle on the right. Wrapped in [AppCard] with the standard
/// `plain` treatment.
///
/// Initials for the avatar fallback are derived from [title] (first
/// letter of the first two words). If the person has a photo, pass
/// [avatarUrl].
///
/// Primitive props only. Feature code maps its domain model (Profile,
/// TeamMembership, etc.) into these fields at the call site.
class AppProfileHeader extends StatelessWidget {
  const AppProfileHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
  });

  final String title;
  final String? subtitle;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final parts = title.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : null;
    final lastName = parts.length > 1 ? parts[1] : null;

    return AppCard(
      variant: AppCardVariant.featured,
      prominent: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: avatarUrl,
            firstName: firstName,
            lastName: lastName,
            size: AppAvatarSize.large,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.anybody(fontSize: 24, color: colors.primaryText),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
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
}
