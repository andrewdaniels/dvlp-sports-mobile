import 'package:flutter/material.dart';

/// Wraps a page body so tapping anywhere outside a focused input
/// dismisses the keyboard.
///
/// Standard iOS platform expectation — the OS keyboard doesn't
/// auto-dismiss on outside taps, so form-bearing pages need this
/// pattern to feel native. `HitTestBehavior.opaque` ensures the
/// tap catcher receives events even where the body is empty.
///
/// Use as the top-level wrapper of a form-bearing Scaffold body:
///
///   Scaffold(
///     body: KeyboardDismissible(
///       child: ListView(...),
///     ),
///   )
class KeyboardDismissible extends StatelessWidget {
  const KeyboardDismissible({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
