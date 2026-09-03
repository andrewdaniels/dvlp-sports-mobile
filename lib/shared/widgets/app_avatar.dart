import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Standard avatar with a 3-tier fallback:
///
/// 1. If [imageUrl] is provided and loads → show image
/// 2. Else if [firstName] or [lastName] is provided → show initials
/// 3. Else → show `user-01` icon from Untitled UI
///
/// Sizes:
/// - `AppAvatarSize.small`  — 32
/// - `AppAvatarSize.medium` — 48
/// - `AppAvatarSize.large`  — 72
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.size = AppAvatarSize.medium,
  });

  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final AppAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimension = _dimension;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: ClipOval(
        child: Container(
          color: colors.alternate,
          alignment: Alignment.center,
          child: hasImage
              ? Image.network(
                  imageUrl!,
                  width: dimension,
                  height: dimension,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(context, dimension),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _fallback(context, dimension);
                  },
                )
              : _fallback(context, dimension),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context, double dimension) {
    final colors = context.colors;
    final initials = _initials;
    if (initials != null) {
      return Text(
        initials,
        style: _textStyle.copyWith(color: colors.primaryText),
      );
    }
    return AppIcon(
      AppIcons.userFallback,
      size: dimension * 0.6,
      color: colors.secondaryText,
    );
  }

  String? get _initials {
    final f = firstName?.trim();
    final l = lastName?.trim();
    final first = (f != null && f.isNotEmpty) ? f[0].toUpperCase() : '';
    final last = (l != null && l.isNotEmpty) ? l[0].toUpperCase() : '';
    final combined = '$first$last';
    return combined.isEmpty ? null : combined;
  }

  double get _dimension {
    switch (size) {
      case AppAvatarSize.small:
        return 32;
      case AppAvatarSize.medium:
        return 48;
      case AppAvatarSize.large:
        return 72;
    }
  }

  /// Initials should read as ~35–40% of the avatar diameter to feel
  /// balanced inside the circle; these tokens are chosen to land in
  /// that range for each size.
  TextStyle get _textStyle {
    switch (size) {
      case AppAvatarSize.small:
        return AppTypography.boldSmall;      // 12 / 32 = 37%
      case AppAvatarSize.medium:
        return AppTypography.titleMedium;    // 18 / 48 = 38%
      case AppAvatarSize.large:
        return AppTypography.titleXLarge;    // 24 / 72 = 33%
    }
  }
}

enum AppAvatarSize { small, medium, large }
