import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_icon_indicator.dart';

/// Actionable to-do row surfaced on coach dashboard surfaces (Games,
/// Home). Layout:
///
///   ┌────────────────────────────────────────────────┐
///   │ (●)  Title                                  ›  │
///   │      Subtitle                                  │
///   └────────────────────────────────────────────────┘
///
/// Composition is deliberate — the primitives (AppCard, AppIconIndicator,
/// AppChevronRight) already exist. This widget owns only:
///   - fixed row layout + spacing
///   - haptic on tap
///   - tap forwarding
///
/// Feature-scoped rather than shared: the "to-do" concept is a
/// coach-surface pattern for now (Games post-game reports, Home
/// pending items). If a genuinely non-coach caller appears, promote
/// to shared then.
class TodoRow extends StatelessWidget {
  const TodoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final String subtitle;
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIconIndicator(
              icon: icon,
              color: iconColor,
              size: AppIconIndicatorSize.medium,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }
}
