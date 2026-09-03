import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_games.dart';
import '../../auth/data/api_result.dart';
import '../data/games_repository.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(SupabaseService.client);
});

/// Games cache — keyed by `teamId` so multiple teams can be cached
/// independently. Lazy per-team; the first `ref.watch` for a given team
/// triggers the fetch, subsequent watchers get the cached value.
///
/// Session-lifetime with no TTL. Invalidated via:
/// - `refresh()` — pull-to-refresh
/// - `optimisticSet(...)` — after a mutation (submit-game, edit-recap)
/// - `ref.invalidate(gamesProvider)` — on sign-out (nukes all teams)
final gamesProvider =
    AsyncNotifierProvider.family<GamesNotifier, GetGamesData?, String>(
  GamesNotifier.new,
);

class GamesNotifier extends FamilyAsyncNotifier<GetGamesData?, String> {
  @override
  Future<GetGamesData?> build(String teamId) async {
    // No session → no fetch. UI treats null as "not signed in / no data".
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref.read(gamesRepositoryProvider).getGames(teamId: teamId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Swap the cached value directly — for mutation flows that already
  /// have the fresh list in hand (e.g., after submitting a game).
  void optimisticSet(GetGamesData games) {
    state = AsyncData(games);
  }

  /// Force a network refetch (pull-to-refresh or after external changes).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(gamesRepositoryProvider).getGames(teamId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}
