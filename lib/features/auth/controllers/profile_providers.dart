import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/create_profile.dart' hide RoleTier;
import '../../../generated/api/get_linked_athletes.dart';
import '../../../generated/api/get_profile.dart';
import '../../../generated/api/update_profile.dart' as up;
import '../../assessments/controllers/assessments_providers.dart';
import '../../coach_feedback/controllers/coach_feedback_providers.dart';
import '../../feedback_requests/controllers/feedback_requests_providers.dart';
import '../../home/controllers/coach_home_providers.dart';
import '../../journal/controllers/journal_providers.dart';
import '../../notifications/controllers/notifications_providers.dart';
import '../../skills/controllers/skills_providers.dart';
import '../../team/controllers/games_providers.dart';
import '../../team/controllers/team_roster_providers.dart';
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

  /// Same bridge as [optimisticSetFromCreate] but for the update-profile
  /// response — the response schema is identical to Profile.
  void optimisticSetFromUpdate(up.UpdateProfileData updated) {
    state = AsyncData(GetProfileData.fromJson(updated.toJson()));
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

/// Profile cache for an ARBITRARY athlete — used by coach flows (and
/// later parent / manager flows) to read someone else's profile.
///
/// Keyed by `athleteId` so multiple athletes can be cached
/// independently (e.g., coach navigating between roster players).
/// Session-lifetime, no TTL. Invalidated on sign-out via
/// [profileAuthSyncProvider].
///
/// Server-side, get-profile enforces `coach_can_access_athlete` when
/// the target isn't the caller. A 403 comes back as a Failure that
/// this provider surfaces as null.
final athleteProfileProvider =
    AsyncNotifierProvider.family<AthleteProfileNotifier, GetProfileData?, String>(
  AthleteProfileNotifier.new,
);

class AthleteProfileNotifier
    extends FamilyAsyncNotifier<GetProfileData?, String> {
  @override
  Future<GetProfileData?> build(String athleteId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(profileRepositoryProvider)
        .getProfile(athleteId: athleteId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(profileRepositoryProvider)
          .getProfile(athleteId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// Athletes linked to the caller via `athlete_guardians`. Only meaningful
/// for guardian sessions — the provider short-circuits and returns an
/// empty list for any other role so the endpoint isn't called at all.
///
/// Session-lifetime, no TTL. Invalidated on sign-in/out via
/// [profileAuthSyncProvider]. Also invalidate manually after a new
/// athlete-link is created (e.g. via a future "Add from invite code"
/// affordance on the guardian profile) so the picker list refreshes.
final linkedAthletesProvider =
    AsyncNotifierProvider<LinkedAthletesNotifier, List<Athlete>>(
  LinkedAthletesNotifier.new,
);

class LinkedAthletesNotifier extends AsyncNotifier<List<Athlete>> {
  @override
  Future<List<Athlete>> build() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return const [];
    // Only guardians have linked athletes — skip the fetch otherwise.
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile?.roleTier != RoleTier.GUARDIAN) return const [];

    final result = await ref.read(profileRepositoryProvider).getLinkedAthletes();
    return switch (result) {
      Success(:final data) => data.athletes,
      Failure() => const [],
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = await ref.read(currentProfileProvider.future);
      if (profile?.roleTier != RoleTier.GUARDIAN) return const <Athlete>[];
      final result = await ref.read(profileRepositoryProvider).getLinkedAthletes();
      return switch (result) {
        Success(:final data) => data.athletes,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// The athlete id whose data the athlete-shell tabs should display for
/// the current session.
///   - Athlete session → their own id.
///   - Guardian session → the currently-selected linked athlete's id
///     (defaults to the first linked athlete; mutable via
///     `.state = newId` when a future picker ships).
///   - Coach / unknown / not-signed-in → null; the athlete shell
///     shouldn't render for these roles anyway.
///
/// A StateProvider (not derived) so a future "switch athlete" UI can
/// mutate the selection without any provider redesign — downstream
/// family providers (assessmentsProvider(id), etc.) auto-refetch when
/// this changes because Riverpod treats a new family key as a fresh
/// cache slot.
final viewingAthleteIdProvider = StateProvider<String?>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  if (profile == null) return null;
  if (profile.roleTier == RoleTier.ATHLETE) return profile.id;
  if (profile.roleTier == RoleTier.GUARDIAN) {
    final linked = ref.watch(linkedAthletesProvider).value ?? const [];
    return linked.isEmpty ? null : linked.first.id;
  }
  return null;
});

/// The full Profile of the athlete the shell is currently viewing.
///   - Athlete → passes through `currentProfileProvider` (no extra fetch).
///   - Guardian → fetches via `athleteProfileProvider(linkedAthleteId)`
///     (already used by coach flows; server permits guardians via the
///     `can_view_athlete` helper).
///
/// Athlete-shell tabs should watch this instead of `currentProfileProvider`
/// so the same code path renders the right athlete's data regardless
/// of whether the caller is the athlete themselves or a linked guardian.
final viewingAthleteProvider = Provider<AsyncValue<GetProfileData?>>((ref) {
  final currentAsync = ref.watch(currentProfileProvider);
  final currentProfile = currentAsync.value;
  if (currentAsync.isLoading || currentProfile == null) return currentAsync;

  if (currentProfile.roleTier == RoleTier.ATHLETE) {
    return AsyncData(currentProfile);
  }

  if (currentProfile.roleTier == RoleTier.GUARDIAN) {
    final viewingId = ref.watch(viewingAthleteIdProvider);
    if (viewingId == null) {
      // Guardian with no linked athletes yet — surface as null so the
      // UI can render an empty state. Shouldn't happen today (guardians
      // are only created as the counterparty of an athlete signup) but
      // defensive against future edge cases.
      return const AsyncData(null);
    }
    return ref.watch(athleteProfileProvider(viewingId));
  }

  // Non-athlete / non-guardian roles shouldn't hit the athlete shell.
  return const AsyncData(null);
});

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
          // Fresh identity — pull the profile AND nuke all user-scoped
          // caches. Signing in can follow a sign-out (account switch)
          // or happen on fresh app-start; either way we don't want to
          // display the previous user's data until they pull to refresh.
          notifier.refresh();
          _invalidateUserScopedCaches(ref);
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          // Same identity — just refresh the profile. Token rotation
          // fires this every ~hour; nuking caches here would be a
          // needless refetch storm.
          notifier.refresh();
        case AuthChangeEvent.signedOut:
          notifier.clear();
          _invalidateUserScopedCaches(ref);
        default:
          break;
      }
    },
  );
});

/// Invalidates every provider that caches user-scoped data. Fired on
/// both sign-in and sign-out so an account switch always shows the
/// new user's data on first render — no stale display, no pull-to-
/// refresh dance required.
void _invalidateUserScopedCaches(Ref ref) {
  ref.invalidate(gamesProvider);
  ref.invalidate(teamRosterProvider);
  ref.invalidate(athleteProfileProvider);
  ref.invalidate(linkedAthletesProvider);
  ref.invalidate(assessmentsProvider);
  ref.invalidate(skillProgressProvider);
  ref.invalidate(skillHistoryProvider);
  ref.invalidate(journalEntriesProvider);
  ref.invalidate(coachesProvider);
  ref.invalidate(coachFeedbackSummaryProvider);
  ref.invalidate(composerSchemaProvider);
  ref.invalidate(teamAggregatesProvider);
  ref.invalidate(notificationsProvider);
  ref.invalidate(notificationsLastSeenProvider);
}

// Private mirror of the auth stream so profileAuthSyncProvider can listen
// without pulling in auth_providers.dart and creating a cycle.
final _authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});
