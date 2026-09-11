import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Coach-side team roster. Placeholder until designs land.
class CoachTeamPage extends StatelessWidget {
  const CoachTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: Center(
        child: Text(
          'Coach Team\n(placeholder)',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
