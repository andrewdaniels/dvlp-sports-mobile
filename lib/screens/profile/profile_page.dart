import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/auth/controllers/auth_providers.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_profile_header.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: profileAsync.when(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                final teamName = profile.teamMemberships.isNotEmpty
                    ? profile.teamMemberships.first.team.name
                    : profile.roleTier.name;
                return AppProfileHeader(
                  title: '${profile.firstName} ${profile.lastName}',
                  subtitle: teamName,
                  avatarUrl: profile.avatarUrl,
                );
              },
              loading: () => const SizedBox(height: 96),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (kDebugMode) ...[
            _ThemeDevTile(),
            _DevToolTile(
              icon: Icons.palette_outlined,
              title: 'Design System',
              subtitle: 'Colors, typography, spacing reference',
              route: RouteNames.designSystem,
            ),
            _DevToolTile(
              icon: Icons.widgets_outlined,
              title: 'Components',
              subtitle: 'Live reference for shared widgets',
              route: RouteNames.components,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
              child: AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.outline,
                size: AppButtonSize.medium,
                expand: true,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(authRepositoryProvider).signOut();
                  // Router redirect will land us on /entry when the auth
                  // state change fires; no manual navigation needed.
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeDevTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final current = ref.watch(themeModeProvider);
    void cycle() {
      HapticFeedback.selectionClick();
      ref.read(themeModeProvider.notifier).state = _next(current);
    }
    return ListTile(
      leading: Icon(_iconFor(current), color: colors.link),
      title: Text(
        'Theme: ${_labelFor(current)}',
        style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
      ),
      onTap: cycle,
    );
  }

  static ThemeMode _next(ThemeMode mode) => switch (mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };

  static String _labelFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  static IconData _iconFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      };
}

class _DevToolTile extends StatelessWidget {
  const _DevToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      leading: Icon(icon, color: colors.link),
      title: Text(title, style: AppTypography.bodyLarge.copyWith(color: colors.primaryText)),
      subtitle: Text(
        subtitle,
        style: AppTypography.captionMedium.copyWith(color: colors.secondaryText),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
    );
  }
}
