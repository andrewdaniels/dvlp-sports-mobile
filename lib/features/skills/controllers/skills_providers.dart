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

/// Skill-history cache — keyed by (skillId, athleteId). athleteId is
/// nullable: null = "self view" (server falls back to the caller's own
/// id via JWT). Coach flows viewing another athlete's drill-in must
/// pass the athlete's id so the record identity survives and the
/// endpoint runs its coach_can_access_athlete check on the right pair.
///
/// Fetched lazily on first watch; the detail sheet is the only
/// subscriber today. Invalidated on sign-out.
typedef SkillHistoryKey = ({String skillId, String? athleteId});

final skillHistoryProvider = AsyncNotifierProvider.family<
    SkillHistoryNotifier, GetSkillHistoryData?, SkillHistoryKey>(
  SkillHistoryNotifier.new,
);

class SkillHistoryNotifier
    extends FamilyAsyncNotifier<GetSkillHistoryData?, SkillHistoryKey> {
  @override
  Future<GetSkillHistoryData?> build(SkillHistoryKey key) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref
        .read(skillsRepositoryProvider)
        .getSkillHistory(skillId: key.skillId, athleteId: key.athleteId);
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(skillsRepositoryProvider).getSkillHistory(
            skillId: arg.skillId,
            athleteId: arg.athleteId,
          );
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}
