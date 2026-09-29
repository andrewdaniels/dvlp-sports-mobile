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
import '../../features/auth/data/api_result.dart';
import '../../generated/api/delete_account.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../shared/widgets/app_detail_app_bar.dart';
import '../../shared/widgets/app_divider.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_link_row.dart';
import '../../shared/widgets/app_snack_bar.dart';

/// Full-screen destination pushed from the Profile page's settings
/// icon. Sections stack top-to-bottom; new sections add a title +
/// AppCard following the same pattern.
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
          Text(
            'Legal',
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _LegalCard(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Account',
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _AccountDangerCard(),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
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

class _LegalCard extends StatelessWidget {
  const _LegalCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppLinkRow(
            label: 'Privacy Policy',
            leadingIcon: AppIcons.fileShield,
            onTap: () {
              // TODO: launch privacy policy URL once the marketing
              // site's legal page is published.
            },
          ),
          const AppDivider(),
          AppLinkRow(
            label: 'Terms of Service',
            leadingIcon: AppIcons.bookClosed,
            onTap: () {
              // TODO: launch terms of service URL once published.
            },
          ),
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

/// Destructive account actions. For now: Delete Account only.
///
/// Delete flow:
///   1. AppConfirmDialog with typed-string gate ("DELETE") — friction
///      for the irreversible action.
///   2. On confirm, invoke AuthRepository.deleteAccount() → edge fn
///      cascades DB delete, removes auth user, fires recovery email.
///   3. On success, signOut() + clear currentProfileProvider, then
///      hard-route to entry with a toast that shows the recovery code
///      inline (user should have the email too but shows here as a
///      belt + suspenders artifact).
///   4. On sole_gm_of_org_with_teams failure, toast the error and
///      leave the page as-is so the user can address it via web.
///   5. On any other failure, toast the error.
class _AccountDangerCard extends ConsumerWidget {
  const _AccountDangerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppLinkRow(
        label: 'Delete Account',
        leadingIcon: AppIcons.trash,
        destructive: true,
        onTap: () => _confirmAndDelete(context, ref),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    // Runs the delete inside the dialog so the CTA can show a loading
    // spinner. Result is captured via the outer var since the dialog's
    // return channel is just yes/no — the follow-on toast + routing
    // need to know Success vs Failure.
    ApiResult<DeleteAccountData>? result;
    await showAppConfirmDialog(
      context: context,
      title: 'Delete your account?',
      message:
          "This permanently deletes your account and profile data. Your "
          "assessment history and scoring data are kept anonymously. "
          "Please confirm below. You'll receive an email with a code "
          "that can be used later on, if you create a new account, to "
          "recover your assessment data.",
      confirmLabel: 'Delete',
      destructive: true,
      typedConfirmationTarget: 'DELETE',
      typedConfirmationLabel: 'Type DELETE to confirm',
      onConfirm: () async {
        result = await ref.read(authRepositoryProvider).deleteAccount();
      },
    );
    if (result == null || !context.mounted) return;

    switch (result!) {
      case Success():
        // Clear the profile cache immediately so the router's auth-gate
        // doesn't briefly try to load a gone user's profile.
        ref.read(currentProfileProvider.notifier).clear();
        await ref.read(authRepositoryProvider).signOut();
        if (!context.mounted) return;
        context.go(RouteNames.entry);
        AppSnackBar.show(
          context,
          message:
              'Account deleted. Check your email for a recovery code you '
              'can use to restore your history.',
        );
      case Failure(:final code, :final message):
        final userMessage = code == 'sole_gm_of_org_with_teams'
            ? 'Reassign or delete your organization on the web app first, '
                'then try again.'
            : message;
        AppSnackBar.show(
          context,
          message: userMessage,
          variant: AppSnackBarVariant.error,
        );
    }
  }
}
