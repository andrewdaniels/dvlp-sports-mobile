import 'package:flutter/material.dart';

/// DVLP brand mark.
///
/// Two sizes only — both callers pick from the enum to keep usage
/// consistent (no `height: 87` sprinkled across screens).
///
/// - [AppLogoSize.hero] — large centered mark on the entry screen
/// - [AppLogoSize.header] — small mark for top-left of onboarding pages
///
/// The asset is a fixed gradient PNG — no color tint prop, because
/// tinting would flatten the gradient. Extend with a `variant` enum
/// if a mono/wordmark asset is delivered later.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppLogoSize.header});

  final AppLogoSize size;

  double get _height {
    switch (size) {
      case AppLogoSize.hero:
        return 96;
      case AppLogoSize.header:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/logo.png',
      height: _height,
      fit: BoxFit.contain,
    );
  }
}

enum AppLogoSize { hero, header }
