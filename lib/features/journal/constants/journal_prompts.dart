/// Copy for the four journal-entry prompts. Single source of truth
/// shared by the entry detail sheet, the (future) New Entry form,
/// and anywhere else that renders a prompt label.
///
/// Column names on `journal_entries` are stable — these strings are
/// the human-facing labels and can evolve without a schema change.
class JournalPrompts {
  JournalPrompts._();

  static const skillsWorkedOn = 'What skills did you work on today?';
  static const performanceReflection = 'How do you feel you performed?';
  static const nextFocus = 'What do you want to work on next?';
  static const additionalNotes = 'Additional Notes';
}
