import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Dev-mode reference page for the design system.
/// Available via Profile → Developer Tools → Design System (debug only).
class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design System'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Spacing'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ColorsTab(),
            _TypographyTab(),
            _SpacingTab(),
          ],
        ),
      ),
    );
  }
}

class _ColorsTab extends StatelessWidget {
  const _ColorsTab();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _colorGroup('Brand', [
          _ColorEntry('primary', colors.primary),
          _ColorEntry('secondary', colors.secondary),
          _ColorEntry('tertiary', colors.tertiary),
          _ColorEntry('alternate', colors.alternate),
          _ColorEntry('onColor', colors.onColor),
        ]),
        _colorGroup('Utility', [
          _ColorEntry('primaryText', colors.primaryText),
          _ColorEntry('secondaryText', colors.secondaryText),
          _ColorEntry('primaryBackground', colors.primaryBackground),
          _ColorEntry('secondaryBackground', colors.secondaryBackground),
          _ColorEntry('primaryBgTint', colors.primaryBgTint),
          _ColorEntry('link', colors.link),
          _ColorEntry('overlay', colors.overlay),
          _ColorEntry('persistDark', colors.persistDark),
          _ColorEntry('primaryText30', colors.primaryText30),
          _ColorEntry('primaryText70', colors.primaryText70),
        ]),
        _colorGroup('Semantic', [
          _ColorEntry('success', colors.success),
          _ColorEntry('successTint', colors.successTint),
          _ColorEntry('error', colors.error),
          _ColorEntry('errorTint', colors.errorTint),
          _ColorEntry('info', colors.info),
        ]),
        _colorGroup('Accent', [
          _ColorEntry('accent1Tint', colors.accent1Tint),
          _ColorEntry('accent2Tint', colors.accent2Tint),
          _ColorEntry('accent3Tint', colors.accent3Tint),
        ]),
      ],
    );
  }

  Widget _colorGroup(String label, List<_ColorEntry> entries) {
    return Builder(builder: (context) {
      final colors = context.colors;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                label.toUpperCase(),
                style: AppTypography.captionSemibold.copyWith(
                  color: colors.secondaryText,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ...entries.map((e) => _ColorRow(entry: e)),
          ],
        ),
      );
    });
  }
}

class _ColorEntry {
  const _ColorEntry(this.name, this.color);
  final String name;
  final Color color;
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.entry});
  final _ColorEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hex = '#${entry.color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.primaryText30, width: 0.5),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: AppTypography.boldMedium.copyWith(color: colors.primaryText)),
                Text(hex, style: AppTypography.captionMedium.copyWith(color: colors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographyTab extends StatelessWidget {
  const _TypographyTab();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final samples = <_TypeSample>[
      _TypeSample('display.large', AppTypography.displayLarge),
      _TypeSample('display.medium', AppTypography.displayMedium),
      _TypeSample('display.small', AppTypography.displaySmall),
      _TypeSample('headline.large', AppTypography.headlineLarge),
      _TypeSample('headline.medium', AppTypography.headlineMedium),
      _TypeSample('headline.small', AppTypography.headlineSmall),
      _TypeSample('title.xlarge', AppTypography.titleXLarge),
      _TypeSample('title.large', AppTypography.titleLarge),
      _TypeSample('title.medium', AppTypography.titleMedium),
      _TypeSample('title.small', AppTypography.titleSmall),
      _TypeSample('label.large', AppTypography.labelLarge),
      _TypeSample('label.medium', AppTypography.labelMedium),
      _TypeSample('label.small', AppTypography.labelSmall),
      _TypeSample('body.large', AppTypography.bodyLarge),
      _TypeSample('body.medium', AppTypography.bodyMedium),
      _TypeSample('body.small', AppTypography.bodySmall),
      _TypeSample('bold.large', AppTypography.boldLarge),
      _TypeSample('bold.medium', AppTypography.boldMedium),
      _TypeSample('bold.small', AppTypography.boldSmall),
      _TypeSample('caption.medium', AppTypography.captionMedium),
      _TypeSample('caption.semibold', AppTypography.captionSemibold),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: samples.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) {
        final s = samples[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.name,
              style: AppTypography.captionSemibold.copyWith(
                color: colors.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'The quick brown fox jumps over the lazy dog',
              style: s.style.copyWith(color: colors.primaryText),
            ),
          ],
        );
      },
    );
  }
}

class _TypeSample {
  const _TypeSample(this.name, this.style);
  final String name;
  final TextStyle style;
}

class _SpacingTab extends StatelessWidget {
  const _SpacingTab();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = <MapEntry<String, double>>[
      const MapEntry('xxs', AppSpacing.xxs),
      const MapEntry('xs', AppSpacing.xs),
      const MapEntry('sm', AppSpacing.sm),
      const MapEntry('md', AppSpacing.md),
      const MapEntry('lg', AppSpacing.lg),
      const MapEntry('xl', AppSpacing.xl),
      const MapEntry('xxl', AppSpacing.xxl),
      const MapEntry('xxxl', AppSpacing.xxxl),
      const MapEntry('huge', AppSpacing.huge),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: AppSpacing.md),
      itemBuilder: (context, i) {
        final e = entries[i];
        return Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                e.key,
                style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${e.value.toInt()}',
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
              ),
            ),
            Expanded(
              child: Container(
                height: 16,
                width: e.value,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
