import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: Center(
        child: Text(
          'Team',
          style: AppTypography.headlineMedium.copyWith(color: context.colors.primaryText),
        ),
      ),
    );
  }
}
