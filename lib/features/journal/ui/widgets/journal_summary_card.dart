import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../controllers/journal_providers.dart';

/// "My Journal" entry-point card on the DVLP page.
///
/// Uses AppCard's `featured` variant + `prominent` flag so it reads
/// as the primary call-to-action above the skills list. Subscribes
/// to `journalEntriesProvider` for the live entry count — same
/// source of truth as the Journal page's "N entries" label, so
/// creating an entry later updates both surfaces at once.
class JournalSummaryCard extends ConsumerWidget {
  const JournalSummaryCard({super.key, required this.athleteId});

  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(journalEntriesProvider(athleteId));
    final entryCount = async.valueOrNull?.entries.length ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(RouteNames.journal);
      },
      child: AppCard(
        variant: AppCardVariant.featured,
        prominent: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(
              AppIcons.edit05,
              size: 28,
              color: colors.primaryText,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Journal',
                    style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _entriesLabel(entryCount),
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
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

  static String _entriesLabel(int count) => count == 1 ? '1 entry' : '$count entries';
}
