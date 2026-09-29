import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Shared confirmation dialog. Two modes:
///
///   1. **Simple confirm** — title + message + Cancel / Confirm buttons.
///      Confirm always enabled.
///
///   2. **Typed-string confirm** — pass [typedConfirmationTarget]. Adds
///      a text input the user must type exactly (case-sensitive) before
///      Confirm enables. For irreversible actions where a stray tap
///      shouldn't be enough (e.g. "type DELETE to confirm").
///
/// Presentation mirrors [showAppSheet] visually — same frosted-glass +
/// primary background + rounded corners — but centered on screen
/// rather than bottom-anchored. Cancel returns `false`; Confirm
/// returns `true`; dismissing outside returns `null`. Caller pattern:
///
/// ```dart
/// final ok = await showAppConfirmDialog(
///   context: context,
///   title: 'Delete account?',
///   message: '...',
///   confirmLabel: 'Delete',
///   typedConfirmationTarget: 'DELETE',
/// );
/// if (ok == true) { ... }
/// ```
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  String? typedConfirmationTarget,
  String? typedConfirmationLabel,
  String? typedConfirmationPlaceholder,
  bool destructive = false,
  bool barrierDismissible = true,
  Future<void> Function()? onConfirm,
}) {
  final colors = context.colors;
  return showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: barrierDismissible,
    barrierColor: colors.overlay,
    builder: (context) => _AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      typedConfirmationTarget: typedConfirmationTarget,
      typedConfirmationLabel: typedConfirmationLabel,
      typedConfirmationPlaceholder: typedConfirmationPlaceholder,
      destructive: destructive,
      onConfirm: onConfirm,
    ),
  );
}

class _AppConfirmDialog extends StatefulWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.typedConfirmationTarget,
    required this.typedConfirmationLabel,
    required this.typedConfirmationPlaceholder,
    required this.destructive,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String? typedConfirmationTarget;
  final String? typedConfirmationLabel;
  final String? typedConfirmationPlaceholder;
  final bool destructive;
  final Future<void> Function()? onConfirm;

  bool get _typedMode => typedConfirmationTarget != null;

  @override
  State<_AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<_AppConfirmDialog> {
  final _typedController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _typedController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _typedController.dispose();
    super.dispose();
  }

  bool get _canConfirm {
    if (_submitting) return false;
    if (!widget._typedMode) return true;
    return _typedController.text == widget.typedConfirmationTarget;
  }

  /// Primary CTA handler. When [widget.onConfirm] is provided, the
  /// async work runs INSIDE the dialog so the CTA can show a loading
  /// spinner + block interaction — otherwise the dialog pops
  /// immediately with `true` and the caller handles the follow-on
  /// async work (which can leave the user staring at the previous
  /// page with no feedback until the work completes). Any thrown
  /// error is swallowed to keep the dialog behaviour predictable; the
  /// dialog closes regardless and the caller inspects outer state.
  Future<void> _handleConfirm() async {
    final onConfirm = widget.onConfirm;
    if (onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await onConfirm();
    } catch (_) {
      // Fall through — dialog closes, caller inspects outer state.
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Same visual language as showAppSheet's frosted surface — blur
    // in dark mode, solid in light mode.
    final surface = Container(
      decoration: BoxDecoration(
        color: isDark
            ? colors.primaryBackground.withValues(alpha: 0.5)
            : colors.primaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: colors.primaryText30, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: AppTypography.titleLarge.copyWith(color: colors.primaryText),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
            if (widget._typedMode) ...[
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: widget.typedConfirmationLabel ??
                    'Type ${widget.typedConfirmationTarget} to confirm',
                placeholder: widget.typedConfirmationPlaceholder ??
                    widget.typedConfirmationTarget,
                controller: _typedController,
                destructive: widget.destructive,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: widget.cancelLabel,
                    variant: AppButtonVariant.outline,
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: widget.confirmLabel,
                    variant: widget.destructive
                        ? AppButtonVariant.destructive
                        : AppButtonVariant.primary,
                    loading: _submitting,
                    onPressed: _canConfirm ? _handleConfirm : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Keyboard handling notes:
    //   * Flutter's Dialog widget already sums `MediaQuery.viewInsets`
    //     into its own padding, so `insetPadding` here stays static
    //     (adding the keyboard on top double-counts and clips).
    //   * Content is wrapped in a bounded SingleChildScrollView so a
    //     tall dialog + open keyboard on a short device scrolls
    //     internally instead of overflowing.
    final mq = MediaQuery.of(context);
    final maxHeight = mq.size.height
        - mq.viewInsets.bottom
        - mq.padding.top
        - mq.padding.bottom
        - AppSpacing.xxl * 2;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: SingleChildScrollView(
            child: isDark
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: surface,
                  )
                : surface,
          ),
        ),
      ),
    );
  }
}
