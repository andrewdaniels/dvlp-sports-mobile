import '../../../generated/api/get_profile.dart';

/// Shared display formatters for [GetProfileData] fields. The backend
/// stores canonical units (cm, kg, ISO dates, enum names) — these
/// helpers translate to the strings the UI actually renders. Missing
/// values return `-` so callers can pass whatever the API gives them
/// without having to null-check first.

/// "M. Thompson" — first initial + `. ` + last name. Compact form used
/// on passport cards where vertical space is tight and the header
/// treatment reads better with an initial.
String formatDisplayName(String? first, String? last) {
  final f = (first ?? '').trim();
  final l = (last ?? '').trim();
  if (f.isEmpty && l.isEmpty) return '';
  if (f.isEmpty) return l;
  if (l.isEmpty) return f;
  return '${f[0].toUpperCase()}. $l';
}

/// "Marcus Thompson" — first + space + last. Used on profile pages
/// (both athlete + coach) and any row rendering the current user's
/// full identity where horizontal space isn't a concern.
String formatFullName(String? first, String? last) {
  final f = (first ?? '').trim();
  final l = (last ?? '').trim();
  if (f.isEmpty && l.isEmpty) return '';
  if (f.isEmpty) return l;
  if (l.isEmpty) return f;
  return '$f $l';
}

/// "14 yo" from an ISO-8601 date-of-birth string.
String formatAge(String? dobIso) {
  if (dobIso == null || dobIso.isEmpty) return '-';
  final dob = DateTime.tryParse(dobIso);
  if (dob == null) return '-';
  final now = DateTime.now();
  var age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return '$age yo';
}

/// `5'9"` from centimeters.
String formatHeight(double? cm) {
  if (cm == null || cm <= 0) return '-';
  final totalInches = (cm / 2.54).round();
  final ft = totalInches ~/ 12;
  final inches = totalInches % 12;
  return "$ft'$inches\"";
}

/// "145 lbs" from kilograms.
String formatWeight(double? kg) {
  if (kg == null || kg <= 0) return '-';
  final lbs = (kg * 2.20462).round();
  return '$lbs lbs';
}

/// "Left" / "Right" / "Both" — UI label for the [DominantSide] enum.
String formatDominantSide(DominantSide? side) => switch (side) {
      DominantSide.LEFT => 'Left',
      DominantSide.RIGHT => 'Right',
      DominantSide.AMBIDEXTROUS => 'Both',
      null => '-',
    };
