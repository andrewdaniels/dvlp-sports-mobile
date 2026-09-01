import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Standard "tap to drill in" chevron used on list rows, settings items,
/// and anywhere else the user is being invited to navigate deeper.
///
/// Enforces consistent size (20px) and default color (`secondaryText`)
/// app-wide. Callers can override `color` per context.
class AppChevronRight extends StatelessWidget {
  const AppChevronRight({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      AppIcons.chevronRight,
      size: 20,
      color: color ?? context.colors.secondaryText,
    );
  }
}
