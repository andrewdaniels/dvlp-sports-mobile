import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_skill_history.dart';
import '../../../generated/api/get_skill_progress.dart';
import '../../auth/data/api_result.dart';
import '../data/skills_repository.dart';

final skillsRepositoryProvider = Provider<SkillsRepository>((ref) {
  return SkillsRepository(SupabaseService.client);
});

/// Skill-progress cache — keyed by `athleteId`. The endpoint derives
/// the athlete's active team's level_classification_id server-side
/// (single-active-team is enforced by a DB partial unique index).
///
/// Lazy per athlete; first watch triggers the fetch, subsequent
/// watchers get the cached value. Session-lifetime, no TTL.
/// Invalidated via `refresh()` or `ref.invalidate(skillProgressProvider)`
/// on sign-out.
final skillProgressProvider = AsyncNotifierProvider.family<
    SkillProgressNotifier, GetSkillProgressData?, String>(
  SkillProgressNotifier.new,
);

class SkillProgressNotifier
    extends FamilyAsyncNotifier<GetSkillProgressData?, String> {
  @override
  Future<GetSkillProgressData?> build(String athleteId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(skillsRepositoryProvider)
        .getSkillProgress(athleteId: athleteId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(skillsRepositoryProvider)
          .getSkillProgress(athleteId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// Skill-history cache — keyed by `skillId` (the current caller is
/// derived from the JWT server-side, so no athlete key needed for the
/// self-view case). Fetched lazily on first watch; the detail sheet
/// is the only subscriber today. Invalidated on sign-out.
final skillHistoryProvider = AsyncNotifierProvider.family<
    SkillHistoryNotifier, GetSkillHistoryData?, String>(
  SkillHistoryNotifier.new,
);

class SkillHistoryNotifier
    extends FamilyAsyncNotifier<GetSkillHistoryData?, String> {
  @override
  Future<GetSkillHistoryData?> build(String skillId) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(skillsRepositoryProvider)
        .getSkillHistory(skillId: skillId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(skillsRepositoryProvider)
          .getSkillHistory(skillId: arg);
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}
