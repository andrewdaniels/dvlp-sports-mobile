import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Multi-line text input. Sibling to `AppTextField` — same visual
/// chrome (label, border, error), but the input area grows
/// vertically instead of staying single-line, and none of the
/// single-line affordances (leading icon, eye toggle, clear button)
/// apply.
///
/// Keeping AppTextArea separate from AppTextField (rather than
/// extending the latter with `minLines`/`maxLines` props) so each
/// primitive's API stays honest to what it does. Chrome duplication
/// between the two is small and worth trading for a clean surface.
/// Extract a private `_AppInputChrome` if that duplication becomes
/// a maintenance burden.
class AppTextArea extends StatefulWidget {
  const AppTextArea({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.minLines = 4,
    this.maxLines = 8,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  /// Vertical growth range. Defaults sized for the journal form's
  /// prompt inputs — 4 lines tall to start, grows to 8 as the user
  /// writes more. Callers can pass `maxLines: null` for unbounded.
  final int minLines;
  final int? maxLines;

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = _resolveBorderColor(colors, hasError: hasError);
    final labelColor = _resolveLabelColor(colors, hasError: hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSmall.copyWith(color: labelColor)),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.secondaryBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            keyboardType: TextInputType.multiline,
            // Return key dismisses the keyboard. The input still
            // renders multi-line (text wraps into the tall box) —
            // we just don't let the user insert an intentional
            // paragraph break by pressing Return. Fine for the
            // journal use case (single-paragraph entries). If
            // multi-paragraph support becomes a real need, switch
            // to TextInputAction.newline and add a keyboard
            // accessory toolbar with a Done button.
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            onChanged: widget.onChanged,
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
            cursorColor: colors.link,
            decoration: InputDecoration.collapsed(
              hintText: widget.placeholder,
              hintStyle: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            widget.errorText!,
            style: AppTypography.labelSmall.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }

  Color _resolveBorderColor(AppColors colors, {required bool hasError}) {
    if (hasError) return colors.error;
    if (!widget.enabled) return colors.alternate.withValues(alpha: 0.5);
    if (_isFocused) return colors.link;
    return colors.alternate;
  }

  Color _resolveLabelColor(AppColors colors, {required bool hasError}) {
    if (hasError) return colors.error;
    if (!widget.enabled) return colors.secondaryText.withValues(alpha: 0.6);
    return colors.secondaryText;
  }
}
