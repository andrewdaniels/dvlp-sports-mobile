import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_games.dart';
import '../../../generated/api/update_game.dart' as update_game;
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

  /// Replace one game in the cached list after a successful mutation
  /// (post-game report submit, score edit, etc.). No refetch; the
  /// server-returned game is the source of truth for the swapped row.
  ///
  /// Takes the update-game response's Game type and maps into the
  /// get-games Game type. The two are structurally identical but
  /// nominally distinct because each function's schema.ts owns its
  /// own local GameSchema — see [[chore-codegen-shared-schemas]]
  /// follow-up which will delete this mapper.
  void replaceGame(update_game.Game returned) {
    final current = state.value;
    if (current == null) return;
    final mapped = _mapUpdatedGame(returned);
    final swapped = current.games
        .map((g) => g.id == mapped.id ? mapped : g)
        .toList(growable: false);
    state = AsyncData(GetGamesData(games: swapped));
  }

  // Stopgap mapper — deleted once shared-schemas codegen (Path A)
  // lands and both endpoints share one canonical `Game` type.
  static Game _mapUpdatedGame(update_game.Game g) => Game(
        id: g.id,
        teamId: g.teamId,
        opponentName: g.opponentName,
        startsAt: g.startsAt,
        location: g.location,
        isHome: g.isHome,
        teamScore: g.teamScore,
        opponentScore: g.opponentScore,
        note: g.note,
        noteCoachId: g.noteCoachId,
      );

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
