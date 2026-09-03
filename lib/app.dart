import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/controllers/profile_providers.dart';
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
      builder: (context, child) {
        for (final path in LevelBadgeAssets.all) {
          precacheImage(AssetImage(path), context);
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
