import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/api_result.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_footer.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../../../shared/widgets/app_text_area.dart';
import '../../constants/journal_prompts.dart';
import '../../controllers/journal_providers.dart';

/// Sheet with the four-prompt New Entry form. Opens from the
/// Journal page's "New Entry" button.
///
/// Contract:
///   - Save disabled while empty (no non-empty field). Enabled once
///     any field has content.
///   - Save disabled + spinner shown while the create request is
///     in-flight (AppButton's `loading` guards taps under the hood).
///   - On success: prepend the new entry to journalEntriesProvider
///     (so the Journal list + DVLP card update without a refetch)
///     and pop the sheet.
///   - On failure: surface an inline error above the footer, keep
///     the form intact so the user can retry.
///   - Clear: reset all controllers + error state.
class JournalEntryFormSheet extends ConsumerStatefulWidget {
  const JournalEntryFormSheet({super.key, required this.athleteId});

  final String athleteId;

  @override
  ConsumerState<JournalEntryFormSheet> createState() => _JournalEntryFormSheetState();
}

class _JournalEntryFormSheetState extends ConsumerState<JournalEntryFormSheet> {
  final _skillsCtrl = TextEditingController();
  final _performanceCtrl = TextEditingController();
  final _nextCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _saving = false;
  String? _error;
  bool _hasAnyContent = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_skillsCtrl, _performanceCtrl, _nextCtrl, _notesCtrl]) {
      c.addListener(_recomputeHasContent);
    }
  }

  @override
  void dispose() {
    for (final c in [_skillsCtrl, _performanceCtrl, _nextCtrl, _notesCtrl]) {
      c.removeListener(_recomputeHasContent);
      c.dispose();
    }
    super.dispose();
  }

  void _recomputeHasContent() {
    final has = [_skillsCtrl, _performanceCtrl, _nextCtrl, _notesCtrl]
        .any((c) => c.text.trim().isNotEmpty);
    if (has != _hasAnyContent && mounted) {
      setState(() => _hasAnyContent = has);
    }
  }

  void _clear() {
    HapticFeedback.lightImpact();
    for (final c in [_skillsCtrl, _performanceCtrl, _nextCtrl, _notesCtrl]) {
      c.clear();
    }
    setState(() => _error = null);
  }

  Future<void> _save() async {
    if (_saving || !_hasAnyContent) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _saving = true;
      _error = null;
    });

    // Send only non-empty fields; the repo omits nulls from the body.
    String? nonEmpty(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    final result = await ref.read(journalRepositoryProvider).createEntry(
          skillsWorkedOn: nonEmpty(_skillsCtrl),
          performanceReflection: nonEmpty(_performanceCtrl),
          nextFocus: nonEmpty(_nextCtrl),
          additionalNotes: nonEmpty(_notesCtrl),
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref
            .read(journalEntriesProvider(widget.athleteId).notifier)
            .prepend(data.entry);
        Navigator.of(context).pop();
      case Failure(:final message):
        setState(() {
          _saving = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppSheetLayout(
      title: 'New Entry',
      subtitle: 'All journal entries are private to you. All prompts are optional.',
      footer: AppScreenFooter.row(
        secondary: AppButton(
          label: 'Clear',
          variant: AppButtonVariant.outline,
          onPressed: _saving ? null : _clear,
        ),
        primary: AppButton(
          label: 'Save Entry',
          variant: AppButtonVariant.primary,
          loading: _saving,
          onPressed: _hasAnyContent && !_saving ? _save : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom labels above the text areas — the design calls for
          // bodyLarge here rather than AppTextArea's default labelSmall.
          // Passing `label: null` to AppTextArea and rendering our own
          // Text keeps the widget's default treatment intact for other
          // callers and doesn't require a variant prop.
          _PromptField(
            prompt: JournalPrompts.skillsWorkedOn,
            placeholder: 'Enter your answer here',
            controller: _skillsCtrl,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PromptField(
            prompt: JournalPrompts.performanceReflection,
            placeholder: 'Enter your answer here',
            controller: _performanceCtrl,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PromptField(
            prompt: JournalPrompts.nextFocus,
            placeholder: 'Enter your answer here',
            controller: _nextCtrl,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PromptField(
            prompt: JournalPrompts.additionalNotes,
            placeholder: 'Enter any thoughts here',
            controller: _notesCtrl,
            enabled: !_saving,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodyMedium.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// bodyLarge prompt label above an AppTextArea (without its own
/// label). Local to the form sheet — no other surface uses this
/// exact combination yet, so keeping it inline instead of shipping
/// another shared widget.
class _PromptField extends StatelessWidget {
  const _PromptField({
    required this.prompt,
    required this.placeholder,
    required this.controller,
    required this.enabled,
  });

  final String prompt;
  final String placeholder;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextArea(
          placeholder: placeholder,
          controller: controller,
          enabled: enabled,
        ),
      ],
    );
  }
}

/// Convenience opener — same pattern as the other sheet openers.
Future<void> showJournalEntryFormSheet(
  BuildContext context, {
  required String athleteId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => JournalEntryFormSheet(athleteId: athleteId),
  );
}
