import 'package:flutter/material.dart';

/// DVLP brand mark.
///
/// Currently just the gradient chevron mark (no wordmark yet). Sized by
/// [height]; width is derived from the asset's natural aspect ratio.
///
/// The asset is a fixed gradient PNG — no `color` tint prop, because
/// tinting would flatten the gradient. If a mono/wordmark variant is
/// delivered later, extend with a `variant` enum.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
