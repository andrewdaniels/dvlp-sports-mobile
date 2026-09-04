import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Thin wrapper around [SvgPicture.asset] that enforces our size/color
/// conventions for Untitled UI icons.
///
/// Icons live under `assets/icons/<category>/<name>.svg` and are named
/// with the Untitled UI convention (kebab-case with optional variant
/// numbers like `01`, `02`).
///
/// Example:
///   AppIcon('assets/icons/nav/book-open-02.svg', size: 24, color: context.colors.primaryText)
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// Well-known icon asset paths.
///
/// The full Untitled UI Icons free set (~1173 SVGs) lives at
/// `assets/icons/untitled/<name>.svg`. When you need a new icon:
///  1. Find its name via the Figma design or on untitledui.com/free-icons
///  2. Add a semantic constant here that points at the file
///  3. Use via `AppIcon(AppIcons.yourNewIcon, ...)`
///
/// Only reference icons via constants — never hardcode string paths in
/// feature code, so we have one place to audit + rename.
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons/untitled';

  // Bottom nav
  static const String navPassport = '$_base/book-open-02.svg';
  static const String navDvlp = '$_base/bar-chart-circle-01.svg';
  static const String navTeam = '$_base/users-01.svg';
  static const String navProfile = '$_base/user-circle.svg';

  // Avatar fallback
  static const String userFallback = '$_base/user-01.svg';

  // Common utility
  static const String chevronRight = '$_base/chevron-right.svg';
  static const String chevronLeft = '$_base/chevron-left.svg';
  static const String chevronDown = '$_base/chevron-down.svg';
  static const String chevronUp = '$_base/chevron-up.svg';
  static const String plus = '$_base/plus.svg';
  static const String arrowRight = '$_base/arrow-right.svg';
  static const String arrowLeft = '$_base/arrow-left.svg';
  static const String close = '$_base/x-close.svg';
  static const String bell = '$_base/bell-03.svg';
  static const String messageQuestionSquare = '$_base/message-question-square.svg';
  static const String settings = '$_base/settings-01.svg';
  static const String edit = '$_base/edit-02.svg';
  static const String edit05 = '$_base/edit-05.svg';
  static const String brush = '$_base/brush-01.svg';
  static const String grid = '$_base/grid-01.svg';
  static const String eye = '$_base/eye.svg';
  static const String eyeOff = '$_base/eye-off.svg';

  // Selection controls
  static const String check = '$_base/check.svg';
  static const String circle = '$_base/circle.svg';
  static const String checkCircle = '$_base/check-circle.svg';

  // Feedback / recognition
  static const String star = '$_base/star-01.svg';
  static const String award = '$_base/award-01.svg';

  // Media / audio
  static const String microphone = '$_base/microphone-01.svg';
  static const String image = '$_base/image-01.svg';
  // Filled variants live under assets/icons/custom/ because Untitled UI's
  // free set is stroke-only. See lib/shared/widgets/app_icon.dart comments
  // for the pattern.
  static const String playFilled = 'assets/icons/custom/play-filled.svg';
  static const String stopFilled = 'assets/icons/custom/stop-filled.svg';
  static const String pauseFilled = 'assets/icons/custom/pause-filled.svg';
}
