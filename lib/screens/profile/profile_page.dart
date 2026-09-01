import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          if (kDebugMode) ...[
            const _SectionHeader(title: 'Developer Tools'),
            const _ThemeSelector(),
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
            _DevToolTile(
              icon: Icons.login_outlined,
              title: 'Preview Onboarding',
              subtitle: 'Entry / login screens (unauth flow)',
              route: RouteNames.entry,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.captionSemibold.copyWith(
          color: colors.secondaryText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final current = ref.watch(themeModeProvider);

    const options = <(ThemeMode, String)>[
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'Theme',
              style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppButton(
                    label: options[i].$2,
                    size: AppButtonSize.xs,
                    variant: current == options[i].$1 ? AppButtonVariant.primary : AppButtonVariant.outline,
                    expand: true,
                    onPressed: () => ref.read(themeModeProvider.notifier).state = options[i].$1,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
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
