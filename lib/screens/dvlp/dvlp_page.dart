import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class DvlpPage extends StatelessWidget {
  const DvlpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DVLP')),
      body: Center(
        child: Text(
          'DVLP',
          style: AppTypography.headlineMedium.copyWith(color: context.colors.primaryText),
        ),
      ),
    );
  }
}
