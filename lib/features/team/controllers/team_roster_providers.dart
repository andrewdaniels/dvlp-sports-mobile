import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_team_roster.dart';
import '../../auth/data/api_result.dart';
import '../data/team_roster_repository.dart';

final teamRosterRepositoryProvider = Provider<TeamRosterRepository>((ref) {
  return TeamRosterRepository(SupabaseService.client);
});

/// Team roster cache — keyed by `teamId` so multiple teams can be
/// cached independently (multi-team coaches, later). Lazy per-team:
/// first `ref.watch` on a team id triggers the fetch, subsequent
/// watchers get the cached value.
///
/// Session-lifetime, no TTL. Invalidated on sign-out via
/// [profileAuthSyncProvider] (which nukes all keyed caches).
final teamRosterProvider =
    AsyncNotifierProvider.family<TeamRosterNotifier, GetTeamRosterData?, String>(
  TeamRosterNotifier.new,
);

class TeamRosterNotifier extends FamilyAsyncNotifier<GetTeamRosterData?, String> {
  @override
  Future<GetTeamRosterData?> build(String teamId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(teamRosterRepositoryProvider)
        .getTeamRoster(teamId: teamId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Force a network refetch (pull-to-refresh or after roster mutations
  /// land — e.g., after adding a player to the team).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(teamRosterRepositoryProvider)
          .getTeamRoster(teamId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}
