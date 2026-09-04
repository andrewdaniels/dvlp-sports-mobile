import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_journal_entries.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';

/// One row in the journal list. Renders a date label above a
/// 2-line-truncated preview composed from the first non-empty prompt
/// field, with an AppChevronRight trailing.
///
/// Feature-scoped — nothing here is reused outside the journal list.
class JournalEntryRow extends StatelessWidget {
  const JournalEntryRow({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = _preview(entry);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatEntryDate(entry.createdAt),
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    preview,
                    style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  /// First non-empty prompt field, in the natural reading order.
  /// Returns an em-dash if the entry has no filled fields (shouldn't
  /// happen once we add form validation on create, but harmless as a
  /// fallback).
  static String _preview(Entry entry) {
    for (final v in [
      entry.skillsWorkedOn,
      entry.performanceReflection,
      entry.nextFocus,
      entry.additionalNotes,
    ]) {
      final trimmed = v?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '—';
  }
}

/// "Aug 21, 2026"-style formatter. Kept inline since the app has no
/// other date-display need at this format yet and pulling `intl` for
/// one label isn't worth it. Extract into a shared formatter if a
/// second surface needs the same style.
String _formatEntryDate(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
