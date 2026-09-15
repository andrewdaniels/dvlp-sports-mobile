import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_team_aggregates.dart';
import '../../auth/data/api_result.dart';
import '../data/coach_home_repository.dart';

final coachHomeRepositoryProvider = Provider<CoachHomeRepository>((ref) {
  return CoachHomeRepository(SupabaseService.client);
});

/// Team aggregates cache — avg tier + per-skill averages for the coach
/// home screen. Keyed by `teamId` so multi-team coaches get separate
/// entries. Lazy fetch; session-lifetime.
///
/// Invalidated by:
///   - sign-out (via profileAuthSyncProvider)
///   - assessment mutations (AssessmentActions.create/update also
///     invalidates this, since a new/edited assessment shifts the
///     team's aggregate scores)
///   - pull-to-refresh on the home page
final teamAggregatesProvider =
    AsyncNotifierProvider.family<TeamAggregatesNotifier, GetTeamAggregatesData?, String>(
  TeamAggregatesNotifier.new,
);

class TeamAggregatesNotifier
    extends FamilyAsyncNotifier<GetTeamAggregatesData?, String> {
  @override
  Future<GetTeamAggregatesData?> build(String teamId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(coachHomeRepositoryProvider)
        .getTeamAggregates(teamId: teamId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(coachHomeRepositoryProvider)
          .getTeamAggregates(teamId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}
