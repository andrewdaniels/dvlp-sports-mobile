import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_coaches.dart';
import '../../auth/data/api_result.dart';
import '../data/feedback_requests_repository.dart';

final feedbackRequestsRepositoryProvider =
    Provider<FeedbackRequestsRepository>((ref) {
  return FeedbackRequestsRepository(SupabaseService.client);
});

/// Coaches available for the current caller to select from — keyed
/// by `athleteId` today (the only caller). Server derives scope from
/// the JWT (athlete → active team; coach → org — coach-side flows
/// land later). Same session-lifetime cache pattern as the other
/// AsyncNotifier families. Invalidated on sign-out.
///
/// When coach-side flows arrive and need to pass explicit filters,
/// we'll either widen the key (compound record) or add sibling
/// providers for those scopes.
final coachesProvider = AsyncNotifierProvider.family<
    CoachesNotifier, GetCoachesData?, String>(
  CoachesNotifier.new,
);

class CoachesNotifier extends FamilyAsyncNotifier<GetCoachesData?, String> {
  @override
  Future<GetCoachesData?> build(String athleteId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    // No explicit filters — server derives from JWT (athlete's
    // active team).
    final result = await ref
        .read(feedbackRequestsRepositoryProvider)
        .getCoaches();
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }
}
