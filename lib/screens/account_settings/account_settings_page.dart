import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_detail_app_bar.dart';
import '../../shared/widgets/app_divider.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_link_row.dart';

/// Full-screen destination pushed from the Profile page's settings
/// icon. Currently only surfaces the debug-only dev tools (theme
/// cycler + design system + components dev pages). Real account
/// settings sections will land here as they ship.
class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: const AppDetailAppBar(title: 'Account Settings'),
      body: ListView(
        padding: AppPageInsets.padding,
        children: [
          if (kDebugMode) ...[
            Text(
              'Developer Tools',
              style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _DevToolsCard(),
          ],
        ],
      ),
    );
  }
}

class _DevToolsCard extends StatelessWidget {
  const _DevToolsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ThemeCyclerRow(),
          const AppDivider(),
          AppLinkRow(
            label: 'Design System',
            description: 'Colors, typography, spacing reference',
            leadingIcon: AppIcons.brush,
            onTap: () => context.push(RouteNames.designSystem),
          ),
          const AppDivider(),
          AppLinkRow(
            label: 'Components',
            description: 'Live reference for shared widgets',
            leadingIcon: AppIcons.grid,
            onTap: () => context.push(RouteNames.components),
          ),
        ],
      ),
    );
  }
}

/// Bespoke row for cycling ThemeMode. Not a link (it toggles in place
/// rather than navigating), so it stays as its own tile instead of
/// bending AppLinkRow into a toggle widget.
class _ThemeCyclerRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final current = ref.watch(themeModeProvider);
    return ListTile(
      leading: Icon(_iconFor(current), color: colors.link),
      title: Text(
        'Theme: ${_labelFor(current)}',
        style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeModeProvider.notifier).state = _next(current);
      },
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
