/// Level bands used across score displays and badge assets.
///
/// The gradient/color helpers this file used to expose (`scoreGradient`,
/// `labelGradient`, `glowColor`, `scoreDarkColor`) are gone — the coin
/// and hero badges are now PNGs with the labels baked in, so we no
/// longer render gradients in code. Reintroduce them here if a future
/// surface needs per-band gradients again.
enum LevelBand { beginner, bronze, silver, gold, elite }
