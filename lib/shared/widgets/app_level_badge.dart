import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Asset paths for level badge PNGs (`assets/badges/`).
///
/// Two shapes:
/// - `hero-<band>.png` — large presentational coin with the band name
///   baked into the image; used with [AppLevelHeroBadge].
/// - `coin-<band>-<sublevel>.png` — small coin with the sub-level roman
///   numeral baked in; used with [AppLevelCoin]. Beginner only has
///   sub-level `1`; other bands go `1..3`.
class LevelBadgeAssets {
  LevelBadgeAssets._();

  static const String _base = 'assets/badges';

  static String hero(LevelBand band) => '$_base/hero-${band.slug}.png';

  static String coin(LevelBand band, int subLevel) =>
      '$_base/coin-${band.slug}-$subLevel.png';

  /// Every badge PNG shipped with the app. Used for one-time precache
  /// on startup so the first paint of any badge is instant.
  static List<String> get all => [
        for (final b in LevelBand.values) hero(b),
        for (final b in LevelBand.values)
          for (final n in _subLevelsFor(b)) coin(b, n),
      ];

  static List<int> _subLevelsFor(LevelBand band) =>
      band == LevelBand.beginner ? const [1] : const [1, 2, 3];
}

extension _LevelBandSlug on LevelBand {
  String get slug => switch (this) {
        LevelBand.beginner => 'beginner',
        LevelBand.bronze => 'bronze',
        LevelBand.silver => 'silver',
        LevelBand.gold => 'gold',
        LevelBand.elite => 'elite',
      };
}

/// Small level indicator — a coin with the sub-level (I / II / III)
/// baked into the PNG. Fixed 48×48 so it drops into rows and headers
/// without size fussing.
///
/// Beginner has only sub-level `1`. Other bands accept `1..3`.
class AppLevelCoin extends StatelessWidget {
  const AppLevelCoin({
    super.key,
    required this.band,
    this.subLevel = 1,
  }) : assert(subLevel >= 1 && subLevel <= 3);

  final LevelBand band;
  final int subLevel;

  static const double dim = 48;

  @override
  Widget build(BuildContext context) {
    final effective = band == LevelBand.beginner ? 1 : subLevel;
    return Image.asset(
      LevelBadgeAssets.coin(band, effective),
      width: dim,
      height: dim,
      fit: BoxFit.contain,
    );
  }
}

/// Large presentational badge — hero coin PNG with the band name baked
/// into the image. Fixed 240×240. Use for passport hero blocks and
/// other marketing surfaces.
class AppLevelHeroBadge extends StatelessWidget {
  const AppLevelHeroBadge({super.key, required this.band});

  final LevelBand band;

  static const double dim = 240;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      LevelBadgeAssets.hero(band),
      width: dim,
      height: dim,
      fit: BoxFit.contain,
    );
  }
}
