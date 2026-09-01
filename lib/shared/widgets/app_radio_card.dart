import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_card.dart';
import 'app_icon.dart';

/// Radio indicator:
/// - Inactive: 2px outlined circle in [color]
/// - Active: filled circle in [color] with a dark check on top (persistDark
///   so it reads in both modes)
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: selected ? null : Border.all(color: color, width: 2),
      ),
      child: selected
          ? AppIcon(AppIcons.check, size: 14, color: colors.persistDark)
          : null,
    );
  }
}

/// Card-shaped radio option. Use in mutually-exclusive groupings (coach
/// selection, level classification, etc).
///
/// Layout: `[indicator]` 12px gap `[title (optional subtitle)]`
///
/// - Indicator: `circle` (inactive) or `check-circle` filled `secondary` (active)
/// - Title (required): `boldLarge`, `primaryText`
/// - Subtitle (optional): `labelSmall`, `secondaryText`
/// - Wraps in an [AppCard] with `highlighted: selected` so the whole card
///   picks up the gold border + gradient when selected
/// - Light haptic on tap
///
/// Caller manages group state — pass `selected: value == groupValue` for
/// standard radio semantics.
class AppRadioCard extends StatelessWidget {
  const AppRadioCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onTap == null;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    final titleColor = disabled ? colors.secondaryText : colors.primaryText;
    final subtitleColor = colors.secondaryText;
    final indicatorColor = disabled
        ? colors.secondaryText
        : (selected ? colors.secondary : colors.secondaryText);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        variant: selected ? AppCardVariant.featured : AppCardVariant.plain,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RadioIndicator(selected: selected, color: indicatorColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.boldLarge.copyWith(color: titleColor)),
                  if (hasSubtitle) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle!, style: AppTypography.labelSmall.copyWith(color: subtitleColor)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
