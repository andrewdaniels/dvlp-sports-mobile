import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Coach-side games list. Placeholder until designs land.
class CoachGamesPage extends StatelessWidget {
  const CoachGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: Center(
        child: Text(
          'Coach Games\n(placeholder)',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
