import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Standard text input.
///
/// - Optional [label] above the field (color adapts per state)
/// - Optional [leadingIcon] on the left (from `AppIcons`)
/// - Trailing affordance (when text is present + enabled):
///   * `obscureText: true`  → eye toggle to reveal/hide the password
///   * `obscureText: false` → `x-close` clear button
/// - Border color reflects state: default → focused → disabled → error
/// - [errorText], if non-null, triggers error styling and renders below
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.leadingIcon,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? leadingIcon;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  late bool _obscured;
  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the caller flips obscureText, reset visibility to obscured.
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    // Rebuild to show/hide the clear button as text changes.
    if (mounted) setState(() {});
  }

  void _clear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _toggleObscure() {
    HapticFeedback.lightImpact();
    setState(() => _obscured = !_obscured);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = _resolveBorderColor(colors, hasError: hasError);
    final labelColor = _resolveLabelColor(colors, hasError: hasError);
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelSmall.copyWith(color: labelColor)),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.secondaryBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ...[
                AppIcon(widget.leadingIcon!, size: 20, color: colors.secondaryText),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscured,
                  onChanged: widget.onChanged,
                  style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                  cursorColor: colors.link,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                  ),
                ),
              ),
              if (widget.enabled && hasText) ...[
                const SizedBox(width: AppSpacing.sm),
                if (widget.obscureText)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleObscure,
                    child: AppIcon(
                      _obscured ? AppIcons.eye : AppIcons.eyeOff,
                      size: 20,
                      color: colors.secondaryText,
                    ),
                  )
                else
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: AppIcon(AppIcons.close, size: 18, color: colors.secondaryText),
                  ),
              ],
            ],
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
    if (_isFocused) return colors.link;
    return colors.secondaryText;
  }
}
