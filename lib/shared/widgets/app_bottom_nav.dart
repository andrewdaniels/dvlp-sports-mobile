import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Bottom navigation bar per Figma design.
///
/// - 4 tabs, icon on top + label below
/// - Selected: `brand.secondary` (yellow) icon+label, SemiBold label
/// - Unselected: `utility.secondaryText` icon+label, Regular label
/// - Frosted-glass backdrop (blur behind the bar) — straight top edge (no
///   corner rounding) per Figma
/// - Subtle top divider (`primaryText30`) edge to edge — visible even when
///   there's no scrolled content behind the bar
/// - Bottom safe-area padding baked in via [SafeArea]
/// - Light haptic on tap (per AGENTS.md haptic rules — navigation = light)
///
/// Requires the hosting [Scaffold] to set `extendBody: true` so page content
/// can render behind the nav for the blur effect to be visible.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: colors.primaryBackground.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(color: colors.primaryText30, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _NavItem(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(i);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.iconAsset,
    required this.label,
  });

  final String iconAsset;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.secondary : colors.secondaryText;
    final labelStyle = (selected ? AppTypography.boldSmall : AppTypography.bodySmall).copyWith(color: color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(item.iconAsset, size: 24, color: color),
            const SizedBox(height: 6),
            Text(item.label, style: labelStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
