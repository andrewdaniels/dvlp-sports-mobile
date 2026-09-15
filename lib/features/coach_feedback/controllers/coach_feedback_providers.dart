import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_coach_feedback_summary.dart';
import '../../auth/data/api_result.dart';
import '../data/coach_feedback_repository.dart';

final coachFeedbackRepositoryProvider = Provider<CoachFeedbackRepository>((ref) {
  return CoachFeedbackRepository(SupabaseService.client);
});

/// Coach's Feedback-page summary cache.
///
/// Singleton (not family) — a coach has one active team at a time in
/// V1 and the summary endpoint resolves the team server-side from the
/// caller's JWT. When the multi-team switcher lands, this becomes a
/// family keyed by team_id and the endpoint gains a team_id request
/// field.
///
/// Session-lifetime, no TTL. Invalidated on sign-out via
/// [profileAuthSyncProvider]. Mutations patch state locally via
/// [applyAssessmentCreated] rather than invalidating — feels instant
/// on the sim vs waiting for a full round trip.
final coachFeedbackSummaryProvider =
    AsyncNotifierProvider<CoachFeedbackSummaryNotifier, GetCoachFeedbackSummaryData?>(
  CoachFeedbackSummaryNotifier.new,
);

class CoachFeedbackSummaryNotifier
    extends AsyncNotifier<GetCoachFeedbackSummaryData?> {
  @override
  Future<GetCoachFeedbackSummaryData?> build() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref.read(coachFeedbackRepositoryProvider).getSummary();
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Force a network refetch (pull-to-refresh, or after mutations that
  /// affect the summary — e.g., submitting a formal assessment).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(coachFeedbackRepositoryProvider).getSummary();
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }

  /// Surgically patch the summary in place after a successful
  /// create-assessment. Instant UI update without a full refetch —
  /// mirrors the games.replaceGame pattern.
  ///
  /// Slice-by-slice:
  ///   - `pending_athletes` → drop the athlete's row (if present)
  ///   - `completed_count`  → +1 iff the athlete was pending AND the
  ///     new assessment is formal
  ///   - `quick_feedback_requests` → drop the fulfilled row (if
  ///     [requestId] provided)
  ///   - `recent_completed` → prepend the new row, cap to server
  ///     limit (10) so the visible list stays stable
  ///
  /// No-op when the summary hasn't loaded yet (nothing to patch).
  void applyAssessmentCreated({
    required String athleteId,
    required AssessmentType assessmentType,
    required String assessmentId,
    required String submittedAt,
    String? requestId,
  }) {
    final current = state.value;
    if (current == null) return;

    // Snapshot the athlete's display fields from whichever list they're
    // in, so the new "Recent Completed" row has real name + avatar.
    final pending = current.formalCadence.pendingAthletes;
    final requests = current.quickFeedbackRequests;
    final matchingPending = pending.where((p) => p.athlete.id == athleteId).firstOrNull;
    final matchingRequest = requests.where((r) => r.athlete.id == athleteId).firstOrNull;
    final athleteFirstName = matchingPending?.athlete.firstName ??
        matchingRequest?.athlete.firstName ??
        '';
    final athleteLastName = matchingPending?.athlete.lastName ??
        matchingRequest?.athlete.lastName ??
        '';
    final athleteAvatarUrl = matchingPending?.athlete.avatarUrl ??
        matchingRequest?.athlete.avatarUrl;

    // Formal + was-pending → move the athlete into the completed count.
    final wasPending = matchingPending != null;
    final newCompletedCount =
        (wasPending && assessmentType == AssessmentType.FORMAL)
            ? current.formalCadence.completedCount + 1
            : current.formalCadence.completedCount;

    final newPending = wasPending
        ? pending.where((p) => p.athlete.id != athleteId).toList()
        : pending;

    final newRequests = requestId != null
        ? requests.where((r) => r.requestId != requestId).toList()
        : requests;

    final newRow = RecentCompleted(
      assessmentId: assessmentId,
      assessmentType: assessmentType,
      submittedAt: submittedAt,
      athlete: RecentCompletedAthlete(
        id: athleteId,
        firstName: athleteFirstName,
        lastName: athleteLastName,
        avatarUrl: athleteAvatarUrl,
      ),
    );
    // Cap = 10 matches the server-side RECENT_LIMIT so the client's
    // view stays in sync with what a fresh fetch would return.
    final newRecentCompleted = [newRow, ...current.recentCompleted].take(10).toList();

    state = AsyncData(current.copyWith(
      formalCadence: current.formalCadence.copyWith(
        pendingAthletes: newPending,
        completedCount: newCompletedCount,
      ),
      quickFeedbackRequests: newRequests,
      recentCompleted: newRecentCompleted,
    ));
  }
}
