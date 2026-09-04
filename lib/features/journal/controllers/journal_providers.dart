import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/create_journal_entry.dart' as create_api;
import '../../../generated/api/get_journal_entries.dart';
import '../../auth/data/api_result.dart';
import '../data/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(SupabaseService.client);
});

/// Journal-entries cache — keyed by `athleteId`. Same pattern as the
/// other keyed list providers (assessmentsProvider, gamesProvider).
///
/// Two subscribers today:
///   - DVLP `JournalSummaryCard` — reads the count for its subtitle
///   - `JournalPage` — renders the full list
///
/// Both surfaces stay in sync via the shared provider. Once
/// create-journal-entry lands, calling `refresh()` after a successful
/// mutation updates both places at once.
final journalEntriesProvider = AsyncNotifierProvider.family<
    JournalEntriesNotifier, GetJournalEntriesData?, String>(
  JournalEntriesNotifier.new,
);

class JournalEntriesNotifier
    extends FamilyAsyncNotifier<GetJournalEntriesData?, String> {
  @override
  Future<GetJournalEntriesData?> build(String athleteId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(journalRepositoryProvider)
        .getEntries(athleteId: athleteId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(journalRepositoryProvider)
          .getEntries(athleteId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }

  /// Optimistically prepend a newly-created entry to the cached list
  /// so the Journal page and DVLP card update without a refetch.
  /// The create endpoint returns the same row shape as the list
  /// endpoint (identical columns), so we field-copy across the
  /// codegen-generated Entry types.
  void prepend(create_api.Entry newEntry) {
    final current = state.valueOrNull;
    final converted = Entry(
      id: newEntry.id,
      createdAt: newEntry.createdAt,
      skillsWorkedOn: newEntry.skillsWorkedOn,
      performanceReflection: newEntry.performanceReflection,
      nextFocus: newEntry.nextFocus,
      additionalNotes: newEntry.additionalNotes,
    );
    final nextEntries = <Entry>[converted, ...?current?.entries];
    state = AsyncData(GetJournalEntriesData(entries: nextEntries));
  }
}
