import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Thin horizontal rule in `colors.alternate` with rounded end caps —
/// our standard divider across cards, sheets, and lists. Use in place
/// of Flutter's `Divider` so color, thickness, and cap treatment stay
/// consistent everywhere without every caller remembering the tokens.
///
/// [thickness] controls both height and end-cap radius (a pill of that
/// thickness). Callers manage surrounding space with SizedBox.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.thickness = 1});

  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        color: context.colors.alternate,
        borderRadius: BorderRadius.circular(thickness),
      ),
    );
  }
}
