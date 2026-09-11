import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Coach-side feedback inbox. Placeholder until designs land — this
/// tab will surface incoming athlete requests + the coach's
/// submitted-assessments history.
class CoachFeedbackPage extends StatelessWidget {
  const CoachFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Center(
        child: Text(
          'Coach Feedback\n(placeholder)',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}
