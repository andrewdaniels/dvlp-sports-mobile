import 'package:flutter/services.dart';

/// Phone number handling for the mobile client.
///
/// Wire format is E.164 (`+1XXXXXXXXXX`). UI masks input as
/// `(XXX) XXX-XXXX` while the user types; on submit the caller strips
/// the mask via [toE164]. On display, [formatFromE164] renders the
/// E.164 back to the masked form. Both helpers tolerate malformed /
/// legacy raw values so pre-tightening DB rows still display.
///
/// Scoped to North America (NANP, `+1` + 10 digits) — matches the
/// backend schema regex on create-profile + update-profile +
/// create-organization. Same helpers exist on web at
/// `web/lib/shared/util/phone.dart`.

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = _mask(capped);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Convert a masked / partial input to E.164 (`+1XXXXXXXXXX`). Returns
/// null when the digit count isn't exactly 10.
String? toE164(String masked) {
  final digits = masked.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 10) return null;
  return '+1$digits';
}

/// Render an E.164 phone for display.
///   - `+1XXXXXXXXXX` (canonical) → `(XXX) XXX-XXXX`
///   - anything else → returned unchanged (legacy / pre-tightening rows).
String formatFromE164(String value) {
  if (value.length == 12 && value.startsWith('+1')) {
    final digits = value.substring(2);
    if (RegExp(r'^\d{10}$').hasMatch(digits)) return _mask(digits);
  }
  return value;
}

String _mask(String digits) {
  if (digits.isEmpty) return '';
  if (digits.length <= 3) return '($digits';
  if (digits.length <= 6) {
    return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
  }
  return '(${digits.substring(0, 3)}) '
      '${digits.substring(3, 6)}-${digits.substring(6)}';
}
