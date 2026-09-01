import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Circular level badge (Beginner/Bronze/Silver/Gold/Elite) rendered
/// entirely in code — no image assets.
///
/// - 104×104 coin with uniform metallic gradient (`scoreGradient`) filling
///   the whole face — no darker inner region
/// - Thick outer ring visible via 14px padding (creates rim vs face effect
///   without needing to darken the interior)
/// - Inset ridge (subtle dark inner border) for coin-edge definition
/// - Soft outer glow via `AppGradients.glowColor(band)` at low opacity
/// - Score number: Anybody ExtraBold Italic 36, carved-in via band's
///   darker color at low opacity + white highlight shadow — makes the
///   number look transparent-tinted-with-metal-showing-through
/// - "OVERALL" label: Anybody Bold Italic 9, same carved aesthetic
/// - Level name (optional): Anybody ExtraBold Italic 20, gradient-filled
class AppLevelBadge extends StatelessWidget {
  const AppLevelBadge({
    super.key,
    required this.score,
    required this.band,
    this.showLabel = true,
  });

  final int score;
  final LevelBand band;
  final bool showLabel;

  static const double _dim = 104;
  static const double _ringThickness = 14;

  @override
  Widget build(BuildContext context) {
    final ringGradient = AppGradients.scoreGradient(band);
    final labelGradient = AppGradients.labelGradient(band);
    final glow = AppGradients.glowColor(band);
    final numberTint = AppGradients.scoreDarkColor(band);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coin: uniform metallic gradient + outer glow
        Container(
          width: _dim,
          height: _dim,
          padding: const EdgeInsets.all(_ringThickness),
          decoration: BoxDecoration(
            gradient: ringGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.55),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          // Inner face — same gradient, no darkening. The `padding` above
          // gives the visual ring/rim separation.
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ringGradient,
                  shape: BoxShape.circle,
                ),
              ),

              // Polished-dome highlight — soft white radial glow toward the
              // upper portion of the face, gives the coin its "catching
              // light from above" sheen.
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.4),
                    radius: 0.7,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),

              // Inner-face bevel — dark vignette at the outer edge of the
              // face creates the shading at the bottom of the "cup" where
              // the flat face meets the raised rim.
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.30),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Inset ridge — subtle dark inner border (coin-edge lip)
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
              ),

              // Score + OVERALL — carved-in-metal look. Aligned slightly
              // below center to visually balance the Anybody italic (which
              // reads top-heavy when perfectly centered).
              Align(
                alignment: const Alignment(0, 0.15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: AppTypography.anybody(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                      ).copyWith(
                        height: 0.85,
                        color: numberTint.withValues(alpha: 0.65),
                        shadows: [
                          // Dark shadow above/left — suggests the top edge
                          // of the carved recess in shadow
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(-0.5, -0.5),
                            blurRadius: 1,
                          ),
                          // White highlight below/right — light catching
                          // the raised bottom lip of the engraving
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.45),
                            offset: const Offset(0.5, 1),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -3),
                      child: Text(
                        'OVERALL',
                        style: AppTypography.anybody(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ).copyWith(
                          color: numberTint.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.40),
                              offset: const Offset(0.5, 1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (showLabel) ...[
          const SizedBox(height: AppSpacing.sm),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => labelGradient.createShader(bounds),
            child: Text(
              _labelText(band),
              style: AppTypography.anybody(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white, // masked out by ShaderMask
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _labelText(LevelBand band) => switch (band) {
        LevelBand.beginner => 'BEGINNER',
        LevelBand.bronze => 'BRONZE',
        LevelBand.silver => 'SILVER',
        LevelBand.gold => 'GOLD',
        LevelBand.elite => 'ELITE',
      };
}
