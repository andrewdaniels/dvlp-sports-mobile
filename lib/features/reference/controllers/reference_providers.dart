import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_positions.dart';
import '../../auth/data/api_result.dart';
import '../data/reference_repository.dart';

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  return ReferenceRepository(SupabaseService.client);
});

/// Session-lifetime cache of hockey positions. Any widget can
/// `ref.watch(positionsProvider)`; Riverpod dedupes concurrent requests
/// and caches the result until the provider is invalidated.
///
/// Invalidation: pull-to-refresh screens can call
/// `ref.invalidate(positionsProvider)` to force a fresh fetch.
final positionsProvider = FutureProvider<GetPositionsData>((ref) async {
  final result = await ref.read(referenceRepositoryProvider).getPositions();
  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };
});
