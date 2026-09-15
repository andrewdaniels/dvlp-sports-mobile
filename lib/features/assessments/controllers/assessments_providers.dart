import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/create_assessment.dart' as create_api;
import '../../../generated/api/get_assessment_detail.dart' as detail_api;
import '../../../generated/api/get_assessment_schema.dart' as schema_api;
import '../../../generated/api/get_assessments.dart' as list_api;
import '../../../generated/api/get_coach_feedback_summary.dart' as summary_api;
import '../../../generated/api/update_assessment.dart' as update_api;
import '../../auth/data/api_result.dart';
import '../../coach_feedback/controllers/coach_feedback_providers.dart';
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

  /// Surgically patch the cached detail after a successful edit —
  /// avoids a full refetch when the viewer already has the row in
  /// hand. Only the fields the coach actually changed get swapped
  /// (notes + per-skill scores + total_score); coach header, team,
  /// score scale, and previousScore stay untouched.
  ///
  /// [scoresById] replaces the entire score set (matches the server's
  /// replace-all semantics). Skills not in the map keep their prior
  /// value. Skills in the map that don't match an existing score are
  /// ignored (the composer only edits scores that already exist).
  ///
  /// No-op when the cache is empty or the notifier isn't the one
  /// tracking this assessmentId.
  void applyLocalEdit({
    required String? notes,
    required double? totalScore,
    required Map<String, double> scoresById,
  }) {
    final current = state.value;
    if (current == null) return;

    final newScores = [
      for (final s in current.scores)
        scoresById.containsKey(s.skillId)
            ? s.copyWith(score: scoresById[s.skillId])
            : s,
    ];

    state = AsyncData(current.copyWith(
      notes: notes,
      totalScore: totalScore,
      scores: newScores,
    ));
  }
}

/// Composer schema (skills + score_scale) for a team. Keyed by
/// `teamId` so multi-team coaches get separate caches. Lazy fetch;
/// session-lifetime; sign-out invalidation via profileAuthSyncProvider.
final composerSchemaProvider = AsyncNotifierProvider.family<
    ComposerSchemaNotifier, schema_api.GetAssessmentSchemaData?, String>(
  ComposerSchemaNotifier.new,
);

class ComposerSchemaNotifier
    extends FamilyAsyncNotifier<schema_api.GetAssessmentSchemaData?, String> {
  @override
  Future<schema_api.GetAssessmentSchemaData?> build(String teamId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(assessmentsRepositoryProvider)
        .getAssessmentSchema(teamId: teamId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(assessmentsRepositoryProvider)
          .getAssessmentSchema(teamId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// Mutation actions for the assessment composer.
///
/// Pattern: fire the network call, then surgically patch the visible
/// caches from what we already know (call params + server response) —
/// avoids the "return to summary → stare at stale data for a beat →
/// then it snaps" UX that a full invalidate + refetch produces.
///
/// Caches patched:
///   - `coachFeedbackSummaryProvider` — hero pending/completed, requests,
///     recent completed lists (via `applyAssessmentCreated`)
///   - `assessmentDetailProvider(id)` — patched in-place on edit
///
/// Caches NOT patched (invalidated instead — rarely watched in the
/// coach-side flow, so the refetch latency is invisible):
///   - `assessmentsProvider(athleteId)` — athlete's own history list
///
/// Returns the ApiResult for the caller to render success/failure UI
/// (the composer page shows an error on failure and pops on success).
class AssessmentActions {
  const AssessmentActions(this._ref);
  final Ref _ref;

  Future<ApiResult<create_api.CreateAssessmentData>> create({
    required String assessmentType,
    required String athleteId,
    required String teamId,
    required String status,
    String? notes,
    List<({String skillId, num score})> scores = const [],
    String? requestId,
  }) async {
    final result = await _ref.read(assessmentsRepositoryProvider).createAssessment(
          assessmentType: assessmentType,
          athleteId: athleteId,
          teamId: teamId,
          status: status,
          notes: notes,
          scores: scores,
          requestId: requestId,
        );
    if (result case Success(:final data)) {
      // Instant local patch on the coach summary — drops from pending,
      // increments completed count (if formal), prepends recent, drops
      // fulfilled request row (if requestId). No round trip needed.
      _ref.read(coachFeedbackSummaryProvider.notifier).applyAssessmentCreated(
            athleteId: athleteId,
            assessmentType: assessmentType == 'formal'
                ? summary_api.AssessmentType.FORMAL
                : summary_api.AssessmentType.QUICK,
            assessmentId: data.assessmentId,
            submittedAt: data.submittedAt ?? DateTime.now().toIso8601String(),
            requestId: requestId,
          );
      // Athlete's own list rarely watched during the coach flow; a
      // fresh fetch on next visit is acceptable and keeps the code
      // simpler than reconstructing the full Assessment shape locally.
      _ref.invalidate(assessmentsProvider(athleteId));
    }
    return result;
  }

  /// [athleteId] is optional because the get-assessment-detail
  /// response doesn't currently surface athlete_id — edit flows on
  /// the coach side don't have it in hand. When null, we skip the
  /// athlete-list invalidation (that cache goes stale until refresh).
  /// Follow-up: surface athlete_id on the detail response.
  Future<ApiResult<update_api.UpdateAssessmentData>> update({
    required String assessmentId,
    String? athleteId,
    String? status,
    String? notes,
    List<({String skillId, num score})>? scores,
  }) async {
    final result = await _ref.read(assessmentsRepositoryProvider).updateAssessment(
          assessmentId: assessmentId,
          status: status,
          notes: notes,
          scores: scores,
        );
    if (result case Success(:final data)) {
      // Patch the detail cache in place with what changed. Coach header,
      // team, score scale, and previousScore all stay intact — only
      // notes / scores / total_score move.
      _ref.read(assessmentDetailProvider(assessmentId).notifier).applyLocalEdit(
            notes: notes,
            totalScore: data.totalScore,
            scoresById: scores == null
                ? const {}
                : {for (final s in scores) s.skillId: s.score.toDouble()},
          );
      if (athleteId != null) {
        _ref.invalidate(assessmentsProvider(athleteId));
      }
      // Summary's recent_completed row is stale (submitted_at doesn't
      // change on edit; nothing visible to patch there for now). If we
      // later surface total_score on the row we'll add a patch method
      // and drop this invalidate.
      _ref.invalidate(coachFeedbackSummaryProvider);
    }
    return result;
  }
}

final assessmentActionsProvider = Provider<AssessmentActions>(
  (ref) => AssessmentActions(ref),
);
