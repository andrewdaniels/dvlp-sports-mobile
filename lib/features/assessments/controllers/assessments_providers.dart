import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_assessment_detail.dart' as detail_api;
import '../../../generated/api/get_assessments.dart' as list_api;
import '../../auth/data/api_result.dart';
import '../data/assessments_repository.dart';

final assessmentsRepositoryProvider = Provider<AssessmentsRepository>((ref) {
  return AssessmentsRepository(SupabaseService.client);
});

/// Assessments list cache — keyed by `athleteId` so viewing multiple
/// athletes (coach flows, family flows) each get their own entry.
/// Lazy per-athlete; the first `ref.watch` for an id triggers the
/// fetch, subsequent watchers get the cached value.
///
/// Session-lifetime with no TTL. Invalidated via:
/// - `refresh()` — pull-to-refresh
/// - `optimisticSet(...)` — after a mutation with the fresh list in hand
/// - `markLocalAsRead(id)` — surgical patch after the detail endpoint
///   fires its mark-read side effect
/// - `ref.invalidate(assessmentsProvider)` — on sign-out (nukes all)
final assessmentsProvider =
    AsyncNotifierProvider.family<AssessmentsNotifier, list_api.GetAssessmentsData?, String>(
  AssessmentsNotifier.new,
);

class AssessmentsNotifier
    extends FamilyAsyncNotifier<list_api.GetAssessmentsData?, String> {
  @override
  Future<list_api.GetAssessmentsData?> build(String athleteId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(assessmentsRepositoryProvider)
        .getAssessments(athleteId: athleteId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Swap the cached value directly — for mutation flows that already
  /// have the fresh list in hand.
  void optimisticSet(list_api.GetAssessmentsData data) {
    state = AsyncData(data);
  }

  /// Surgical patch: flip a single row's `athleteRead` to `true` in the
  /// cached list, no round trip. Called after the detail endpoint's
  /// mark-read side effect fires server-side. No-op when the row isn't
  /// in this cache or is already read.
  void markLocalAsRead(String assessmentId) {
    final current = state.value;
    if (current == null) return;

    var changed = false;
    final updated = <list_api.Assessment>[];
    for (final a in current.assessments) {
      if (a.id == assessmentId && !a.athleteRead) {
        updated.add(a.copyWith(athleteRead: true));
        changed = true;
      } else {
        updated.add(a);
      }
    }
    if (!changed) return;
    state = AsyncData(list_api.GetAssessmentsData(assessments: updated));
  }

  /// Force a network refetch (pull-to-refresh or after external changes).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(assessmentsRepositoryProvider)
          .getAssessments(athleteId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// Detail cache — keyed by `assessmentId`. Lazy per-id. First watch
/// fetches; subsequent watches return cached.
///
/// On successful fetch, if the returned row is now `athlete_read: true`
/// (server side-effect already ran), we surgically patch the list
/// cache for the same athlete so the passport feed reflects it without
/// a re-fetch.
final assessmentDetailProvider = AsyncNotifierProvider.family<
    AssessmentDetailNotifier, detail_api.Assessment?, String>(
  AssessmentDetailNotifier.new,
);

class AssessmentDetailNotifier
    extends FamilyAsyncNotifier<detail_api.Assessment?, String> {
  @override
  Future<detail_api.Assessment?> build(String assessmentId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(assessmentsRepositoryProvider)
        .getAssessmentDetail(assessmentId);
    return switch (result) {
      Success(:final data) => _syncListCacheOnRead(data.assessment),
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(assessmentsRepositoryProvider)
          .getAssessmentDetail(arg);
      return switch (result) {
        Success(:final data) => _syncListCacheOnRead(data.assessment),
        Failure(:final message) => throw Exception(message),
      };
    });
  }

  /// If the detail response reports `athlete_read: true` and the row
  /// belongs to the current session's athlete, patch the passport list
  /// cache in place. Returns the detail unchanged so callers can chain.
  detail_api.Assessment _syncListCacheOnRead(detail_api.Assessment detail) {
    if (!detail.athleteRead) return detail;
    // Detail response confirms the mark-read side effect ran. The list
    // cache is keyed by athleteId; we don't have that on the detail row
    // itself, so we just patch every list-cache entry that contains this
    // assessment id. Cheap — the notifier bails when the row isn't in
    // its cache.
    ref.read(assessmentsProvider(_currentAthleteId()).notifier)
        .markLocalAsRead(detail.id);
    return detail;
  }

  String _currentAthleteId() {
    // Assessments are always fetched for the signed-in user right now;
    // once coach/family surfaces land we'll pass athleteId through.
    return SupabaseService.client.auth.currentSession?.user.id ?? '';
  }
}
