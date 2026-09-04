import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_journal_entries.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../constants/journal_prompts.dart';

/// Read-only detail view for a journal entry. Opens as a sheet from
/// tapping a row in the journal list. Renders each non-empty prompt
/// as a two-line block: prompt label above, athlete's answer below.
/// Empty prompt fields are hidden entirely — the entry only shows
/// what the athlete wrote.
///
/// Editing an entry is a follow-up. Once we have the New Entry form,
/// this sheet gets an edit affordance that reuses the same form
/// widget in "edit mode".
class JournalEntryDetailSheet extends StatelessWidget {
  const JournalEntryDetailSheet({super.key, required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final sections = <(String prompt, String answer)>[];
    void add(String prompt, String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) sections.add((prompt, trimmed));
    }

    add(JournalPrompts.skillsWorkedOn, entry.skillsWorkedOn);
    add(JournalPrompts.performanceReflection, entry.performanceReflection);
    add(JournalPrompts.nextFocus, entry.nextFocus);
    add(JournalPrompts.additionalNotes, entry.additionalNotes);

    return AppSheetLayout(
      title: _formatEntryDate(entry.createdAt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            _PromptSection(prompt: sections[i].$1, answer: sections[i].$2),
            if (i < sections.length - 1) const SizedBox(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _PromptSection extends StatelessWidget {
  const _PromptSection({required this.prompt, required this.answer});

  final String prompt;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          answer,
          style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
        ),
      ],
    );
  }
}

/// "Aug 21, 2026". Duplicated here from journal_entry_row.dart —
/// small enough to inline; extract to a shared formatter if a third
/// surface needs the same style.
String _formatEntryDate(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

/// Convenience opener. Same pattern as the skill detail sheet.
Future<void> showJournalEntryDetailSheet(
  BuildContext context, {
  required Entry entry,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => JournalEntryDetailSheet(entry: entry),
  );
}
