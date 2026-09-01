import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_logo.dart';

/// Standard header for onboarding pages (invite code entry, welcome,
/// account creation, etc).
///
/// Small logo top-left, page title below (bold), optional subtitle
/// below title (muted).
///
/// Sits inside the Scaffold body — pair with a transparent AppBar
/// above it when the page needs a back button.
class AppOnboardingHeader extends StatelessWidget {
  const AppOnboardingHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: AppLogoSize.header),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppTypography.headlineSmall.copyWith(color: colors.primaryText)),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText)),
        ],
      ],
    );
  }
}
