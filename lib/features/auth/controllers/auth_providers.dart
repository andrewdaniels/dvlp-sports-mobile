import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';

/// Singleton wrapper around the Supabase auth API.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseService.client);
});

/// Stream of Supabase auth state changes. Use this when you need to
/// react to sign-in/sign-out (e.g., router redirects).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Current session, or null if signed out. Watches auth state changes;
/// falls back to the repository's current session for the initial value
/// so subscribers don't get a null flash on first frame.
final currentSessionProvider = Provider<Session?>((ref) {
  final state = ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  return state.value?.session ?? repo.currentSession;
});
