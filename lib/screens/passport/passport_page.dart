import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class PassportPage extends StatelessWidget {
  const PassportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passport')),
      body: Center(
        child: Text(
          'Passport',
          style: AppTypography.headlineMedium.copyWith(color: context.colors.primaryText),
        ),
      ),
    );
  }
}
