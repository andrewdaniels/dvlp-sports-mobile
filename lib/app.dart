import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/controllers/profile_providers.dart';
import 'features/notifications/controllers/notifications_providers.dart';
import 'shared/widgets/app_level_badge.dart';

class DvlpSportsApp extends ConsumerWidget {
  const DvlpSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribes the profile cache to auth state changes for the app's
    // lifetime — refresh on sign-in, clear on sign-out.
    ref.watch(profileAuthSyncProvider);

    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'DVLP Sports',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      // Warm the image cache for all level badge PNGs so the first
      // paint of any badge (passport, feedback rows) has no decode blip.
      // Also mount the app-lifecycle observer that refetches
      // notifications on return-from-background — keeps the bell
      // indicator honest without a poll or a realtime subscription.
      builder: (context, child) {
        for (final path in LevelBadgeAssets.all) {
          precacheImage(AssetImage(path), context);
        }
        return _AppLifecycleWatcher(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Refetches ephemeral providers (currently just notifications) when
/// the app resumes from background. Add more targets here if we take
/// on other short-TTL data (e.g., live game scoring). Keep it lean —
/// invalidating everything on resume defeats session caching.
class _AppLifecycleWatcher extends ConsumerStatefulWidget {
  const _AppLifecycleWatcher({required this.child});
  final Widget child;

  @override
  ConsumerState<_AppLifecycleWatcher> createState() =>
      _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends ConsumerState<_AppLifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
