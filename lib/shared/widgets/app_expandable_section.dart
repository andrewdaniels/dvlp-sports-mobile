import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_divider.dart';
import 'app_icon.dart';

/// Tap-to-expand section with a header row (title + optional
/// subtitle + chevron that swaps down↔up) and an animated body
/// underneath. A bottom `AppDivider` separates one section from
/// the next.
///
/// Deliberately container-free — no border, no background, no
/// rounded corners. Reads as a full-width section grouping, not
/// a card. Owns its own expanded/collapsed state; pass an
/// `initiallyExpanded` if you need to seed it.
///
/// Header hit-test is opaque + spans the full width; safe inside
/// a `Column`/`ListView` without extra alignment plumbing.
class AppExpandableSection extends StatefulWidget {
  const AppExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<AppExpandableSection> createState() => _AppExpandableSectionState();
}

class _AppExpandableSectionState extends State<AppExpandableSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSubtitle = (widget.subtitle ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.titleSmall.copyWith(color: colors.primaryText),
                      ),
                      if (hasSubtitle) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle!,
                          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppIcon(
                  _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                  size: 20,
                  color: colors.secondaryText,
                ),
              ],
            ),
          ),
        ),
        // AnimatedSize expands/collapses the body height smoothly.
        // Wrapping child in a ClipRect prevents overflow flashes
        // during the transition.
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        const AppDivider(),
      ],
    );
  }
}
