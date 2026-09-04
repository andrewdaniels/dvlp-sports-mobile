import 'package:flutter/painting.dart';

/// Level bands used across score displays and badge assets.
///
/// Colors and display names live here as constants — the DB's
/// `level_band_thresholds` intentionally does not carry a `color_hex`
/// column, because band → color is app-scoped brand data (bronze
/// looks the same across sports) and shouldn't be pulled from Postgres
/// on every render. If a shared web app lands, extract this file to
/// a package (or copy with tests).
enum LevelBand { beginner, bronze, silver, gold, elite }

extension LevelBandDisplay on LevelBand {
  /// Brand color for this band. Single source of truth for every
  /// place that renders a band — ScoreGauge pointer/badge, "How it
  /// Works" bands table, future level-badge treatments, etc.
  Color get color => switch (this) {
        LevelBand.beginner => const Color(0xFF3B89FF),
        LevelBand.bronze   => const Color(0xFFB0754F),
        LevelBand.silver   => const Color(0xFFB5BFCF),
        LevelBand.gold     => const Color(0xFFCFA437),
        LevelBand.elite    => const Color(0xFF3ECF8E),
      };

  /// Title-cased display name — "Beginner", "Bronze", etc.
  String get displayName => switch (this) {
        LevelBand.beginner => 'Beginner',
        LevelBand.bronze   => 'Bronze',
        LevelBand.silver   => 'Silver',
        LevelBand.gold     => 'Gold',
        LevelBand.elite    => 'Elite',
      };
}
