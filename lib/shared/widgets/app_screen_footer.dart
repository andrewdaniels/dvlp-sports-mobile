import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_button.dart';

/// Fixed-bottom footer that holds the primary action(s) of a screen.
///
/// Owns four concerns so callers never have to think about them:
///   1. **CTA layout** — pick a factory ([single], [row], [stacked]).
///   2. **Horizontal padding** — defaults to [AppPageInsets.horizontal]
///      so buttons align with page content. Override via
///      [horizontalPadding] for surfaces with a different gutter
///      (e.g., auth pages use `AppSpacing.xl`). Nothing wrapping this
///      widget should also add horizontal padding — that would double
///      up. Place it as a bare sibling of your content column.
///   3. **SafeArea (bottom)** — respects the home indicator inset,
///      whether hosted in `Scaffold.bottomNavigationBar` or at the end
///      of a body Column. Nested SafeAreas are safe: an outer one's
///      inset is consumed automatically.
///   4. **Keyboard visibility** — when the system keyboard is up, the
///      footer collapses to zero height via [AnimatedSize] so it
///      doesn't compete with the input the user is typing into. It
///      re-expands on dismiss. Opt out with `hideOnKeyboard: false`
///      when a screen genuinely needs the CTA visible while typing.
///
/// Keyboard detection uses [WidgetsBindingObserver.didChangeMetrics]
/// + [View.of] rather than MediaQuery.viewInsetsOf. Scaffold's
/// default `resizeToAvoidBottomInset: true` consumes viewInsets from
/// descendants (both body and bottomNavigationBar slots), so a
/// MediaQuery-based check would always report the keyboard hidden.
/// Reading from the raw engine view + rebuilding on metric changes
/// works regardless of Scaffold's resize state.
///
/// Pick the factory that matches the CTA shape:
///  - [single]  — one full-width button
///  - [row]     — two buttons side-by-side, equal width. Primary sits on
///                the right, secondary on the left (iOS convention:
///                destructive/back is outboard).
///  - [stacked] — two full-width buttons in a column. Primary on top,
///                secondary below (matches iOS vertical alert order).
///
/// Callers always pass [AppButton] instances so the CTA type is
/// enforced. Buttons don't need `expand: true`; the footer forces
/// full-width layout for [single] and [stacked], and `Expanded` handles
/// it for [row].
class AppScreenFooter extends StatefulWidget {
  const AppScreenFooter._({
    required this.child,
    this.horizontalPadding,
    this.hideOnKeyboard = true,
  });

  factory AppScreenFooter.single({
    required AppButton primary,
    double? horizontalPadding,
    bool hideOnKeyboard = true,
  }) {
    return AppScreenFooter._(
      horizontalPadding: horizontalPadding,
      hideOnKeyboard: hideOnKeyboard,
      child: SizedBox(width: double.infinity, child: primary),
    );
  }

  factory AppScreenFooter.row({
    required AppButton primary,
    required AppButton secondary,
    double? horizontalPadding,
    bool hideOnKeyboard = true,
  }) {
    return AppScreenFooter._(
      horizontalPadding: horizontalPadding,
      hideOnKeyboard: hideOnKeyboard,
      child: Row(
        children: [
          Expanded(child: secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: primary),
        ],
      ),
    );
  }

  factory AppScreenFooter.stacked({
    required AppButton primary,
    required AppButton secondary,
    double? horizontalPadding,
    bool hideOnKeyboard = true,
  }) {
    return AppScreenFooter._(
      horizontalPadding: horizontalPadding,
      hideOnKeyboard: hideOnKeyboard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: double.infinity, child: primary),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(width: double.infinity, child: secondary),
        ],
      ),
    );
  }

  final Widget child;

  /// Horizontal gutter around the footer content. When null, defaults
  /// to [AppPageInsets.horizontal] so buttons align with standard page
  /// content. Auth pages override to [AppSpacing.xl].
  final double? horizontalPadding;

  /// When true (default), the footer collapses to zero height while
  /// the system keyboard is visible so it doesn't compete with the
  /// input being typed into. Pass false when a screen needs the CTA
  /// to remain visible + tappable while the keyboard is up (e.g., a
  /// send-message composer where the send button must always be
  /// reachable).
  final bool hideOnKeyboard;

  @override
  State<AppScreenFooter> createState() => _AppScreenFooterState();
}

class _AppScreenFooterState extends State<AppScreenFooter>
    with WidgetsBindingObserver {
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First-frame check, in case the widget mounts while a keyboard is
    // already up (deep-linked into a form, etc.).
    _syncKeyboardVisible();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _syncKeyboardVisible();
  }

  void _syncKeyboardVisible() {
    if (!mounted) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = widget.hideOnKeyboard && _keyboardVisible;
    final hPad = widget.horizontalPadding ?? AppPageInsets.horizontal;

    // AnimatedSize interpolates the child's size. To avoid a visible
    // "width scaling" during reappear, the collapsed placeholder
    // takes full available width (infinity) with zero height — so
    // only height animates. easeOutCubic decelerates smoothly at the
    // end, making the footer feel like it settles into place rather
    // than snapping (which easeInOut can do on the reveal).
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: collapsed
          ? const SizedBox(width: double.infinity, height: 0)
          : SafeArea(
              top: false,
              // Bottom SafeArea alone is enough vertical space below
              // the button — matches iOS convention. The keyboard-up
              // case usually gets handled by the collapse above, but
              // when hideOnKeyboard=false we need to add breathing
              // room manually since SafeArea's bottom padding
              // collapses to 0 while the keyboard is consuming the
              // safe area (viewInsets swallow it).
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  AppSpacing.md,
                  hPad,
                  _keyboardVisible ? AppSpacing.md : 0,
                ),
                child: widget.child,
              ),
            ),
    );
  }
}
