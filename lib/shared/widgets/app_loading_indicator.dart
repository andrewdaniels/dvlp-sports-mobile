import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Standard in-page loading spinner. Small (24dp), 2.5px stroke,
/// `primaryText` color. Matches the spinner style baked into
/// `AppButton` when `loading: true`.
///
/// Use anywhere an async surface would otherwise render
/// `CircularProgressIndicator()` — this widget replaces the raw
/// Material spinner with our app-consistent size + tint. Wrap in a
/// `Center` at the call site to center inside a fill; the widget
/// itself does not center (keeps composition explicit).
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.color});

  /// Defaults to `primaryText`. Override for tinted use cases
  /// (e.g., inline on a colored surface).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.colors.primaryText;
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation(resolved),
      ),
    );
  }
}
