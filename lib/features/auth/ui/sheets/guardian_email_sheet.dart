import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_footer.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Modal collected on athlete signup when the DOB indicates the
/// athlete is under 18. Server enforces the age gate too — the sheet
/// is the UX affordance that surfaces WHY the email is needed and
/// lets the athlete confirm before the profile is created.
///
/// Returns the entered email on confirm, or `null` if the athlete
/// dismisses (in which case the caller should abort the signup
/// submit without showing an error — the athlete just decided to
/// back out).
Future<String?> showGuardianEmailSheet({
  required BuildContext context,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (context) => const _GuardianEmailSheet(),
  );
}

class _GuardianEmailSheet extends StatefulWidget {
  const _GuardianEmailSheet();

  @override
  State<_GuardianEmailSheet> createState() => _GuardianEmailSheetState();
}

class _GuardianEmailSheetState extends State<_GuardianEmailSheet> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  void _onChange() {
    final next = _isValidEmail(_controller.text);
    if (next != _valid) setState(() => _valid = next);
  }

  /// Minimal email shape check — final validation happens server-side
  /// via Zod. This just gates the Confirm button so the athlete can't
  /// submit obvious nonsense.
  static bool _isValidEmail(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return false;
    // Anything@anything.anything — permissive enough for typos to
    // still block, strict enough to feel responsive.
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(_controller.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetLayout(
      title: 'Approval Required',
      subtitle:
          'A parent or guardian will need to approve your account '
          'before you can gain access to certain features. '
          'Enter their email address below.',
      footerStaysWithKeyboard: true,
      footer: AppScreenFooter.single(
        // Keep the CTA visible above the keyboard — this sheet is
        // one field + one action, and the user needs the button
        // in view while typing to avoid the "dismiss keyboard to
        // reveal the button" two-step. AppSheetShell already
        // handles the keyboard inset, so the footer sits directly
        // above the keyboard when it's up.
        hideOnKeyboard: false,
        primary: AppButton(
          label: 'Send Invite',
          variant: AppButtonVariant.primary,
          onPressed: _valid ? _confirm : null,
        ),
      ),
      // No extra top padding — AppSheetLayout's bodyPadding already
      // provides breathing room between the header and the field.
      child: AppTextField(
        controller: _controller,
        placeholder: 'guardian@example.com',
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
