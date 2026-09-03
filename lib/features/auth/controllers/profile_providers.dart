import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/create_profile.dart';
import '../../../generated/api/get_profile.dart';
import '../../team/controllers/games_providers.dart';
import '../data/api_result.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(SupabaseService.client);
});

/// The canonical "current user" cache. Auto-fetches via `get-profile`
/// on first watch; kept in memory for the session (no TTL — invalidated
/// only by explicit events: sign in/out, pull-to-refresh, mutations).
///
/// Optimistic updates: any mutation function that returns a fresh
/// Profile (`create-profile`, future `update-profile`) should call
/// `optimisticSet(...)` on this notifier. That swaps the cached value
/// in place without triggering another fetch or invalidating anything.
final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, GetProfileData?>(
  CurrentProfileNotifier.new,
);

class CurrentProfileNotifier extends AsyncNotifier<GetProfileData?> {
  @override
  Future<GetProfileData?> build() async {
    // No session → no fetch. UI treats null as "not signed in".
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref.read(profileRepositoryProvider).getProfile();
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// Called by mutation flows that already have the fresh Profile in
  /// hand (e.g., `create-profile` returns the full Profile after signup).
  /// Bypasses the network — swaps the cached value directly.
  void optimisticSet(GetProfileData profile) {
    state = AsyncData(profile);
  }

  /// Client-side create-profile writes return the identically-shaped
  /// [CreateProfileData]; bridge into the canonical [GetProfileData]
  /// so the cache is one type across the app.
  void optimisticSetFromCreate(CreateProfileData created) {
    state = AsyncData(GetProfileData.fromJson(created.toJson()));
  }

  /// Force a network refetch (pull-to-refresh, or after external changes
  /// we didn't originate).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(profileRepositoryProvider).getProfile();
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }

  /// Called on sign-out.
  void clear() {
    state = const AsyncData(null);
  }
}

/// Watches auth state; refreshes/clears the profile cache as the user
/// signs in or out. Consumed once at app startup (see `main.dart` / the
/// root widget) so it lives for the app's lifetime.
final profileAuthSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthState>>(
    _authStateProvider,
    (previous, next) {
      final event = next.value?.event;
      if (event == null) return;
      final notifier = ref.read(currentProfileProvider.notifier);
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          // Fresh session — pull the latest profile.
          notifier.refresh();
        case AuthChangeEvent.signedOut:
          notifier.clear();
          // Nuke all keyed game caches — new session may belong to a
          // different user with different teams.
          ref.invalidate(gamesProvider);
        default:
          break;
      }
    },
  );
});

// Private mirror of the auth stream so profileAuthSyncProvider can listen
// without pulling in auth_providers.dart and creating a cycle.
final _authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});
