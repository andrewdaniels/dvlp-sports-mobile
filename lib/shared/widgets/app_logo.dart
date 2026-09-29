import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// DVLP brand mark.
///
/// Two variants:
///   - [AppLogoVariant.mark]     — arrow only.
///   - [AppLogoVariant.wordmark] — mark + "DVLP SPORTS" text.
///
/// Three sizes — pick from the enum to keep usage consistent:
///   - [AppLogoSize.hero]   — 96px tall, entry / splash.
///   - [AppLogoSize.medium] — 64px tall, secondary brand moments.
///   - [AppLogoSize.header] — 32px tall, top-left of onboarding pages.
///
/// Sizes are keyed on HEIGHT; the underlying SVG's viewBox preserves
/// aspect ratio so the wordmark variant renders wider than the mark
/// automatically. Assets are gradient SVGs — no color tint prop.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.mark,
    this.size = AppLogoSize.header,
  });

  final AppLogoVariant variant;
  final AppLogoSize size;

  double get _height {
    switch (size) {
      case AppLogoSize.hero:
        return 96;
      case AppLogoSize.medium:
        return 64;
      case AppLogoSize.header:
        return 32;
    }
  }

  String get _asset {
    switch (variant) {
      case AppLogoVariant.mark:
        return 'assets/brand/logo_mark.svg';
      case AppLogoVariant.wordmark:
        return 'assets/brand/logo_wordmark.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      height: _height,
      fit: BoxFit.contain,
    );
  }
}

enum AppLogoVariant { mark, wordmark }

enum AppLogoSize { hero, medium, header }
