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
/// [profileAuthSyncProvider]. Also invalidated when the composer
/// branch lands so that create/update assessment mutations pull a
/// fresh summary.
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
}
