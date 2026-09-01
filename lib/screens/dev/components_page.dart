import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/app_audio_note.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_checkbox.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_game_result_badge.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_icon_indicator.dart';
import '../../shared/widgets/app_level_badge.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_radio_card.dart';
import '../../features/assessments/ui/widgets/app_feedback_list_item.dart';
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_sheet_header.dart';
import '../../shared/widgets/app_sheet_shell.dart';
import '../../shared/widgets/app_star_rating.dart';
import '../../shared/widgets/app_text_field.dart';

/// Dev-mode reference page for shared components.
///
/// Always imports the current live widgets from `lib/shared/widgets/` —
/// what you see here IS what the app is using elsewhere. Add a new section
/// per component as we build them out.
class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Components')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _ComponentSection(
            name: 'AppAvatar',
            description: 'Fallback order: image → initials → user icon',
            child: _AppAvatarDemo(),
          ),
          _ComponentSection(
            name: 'AppButton',
            description: '4 variants · 4 sizes · leading/trailing icons · onPressed=null → disabled · expand for full width',
            child: _AppButtonDemo(),
          ),
          _ComponentSection(
            name: 'AppIconButton',
            description: 'Circular icon-only button. 4 variants (ghost default) · same size scale as AppButton',
            child: _AppIconButtonDemo(),
          ),
          _ComponentSection(
            name: 'AppCard',
            description: 'Default (alternate border) or highlighted (gold border + blue gradient)',
            child: _AppCardDemo(),
          ),
          _ComponentSection(
            name: 'AppIconIndicator',
            description: 'Display-only tinted circular badge. Icon + auto-derived `color @ 15%` background. Use next to list items.',
            child: _AppIconIndicatorDemo(),
          ),
          _ComponentSection(
            name: 'AppGameResultBadge',
            description: 'W/L/T badge for game result rows. Single enum prop drives letter + color.',
            child: _AppGameResultBadgeDemo(),
          ),
          _ComponentSection(
            name: 'AppLevelBadge',
            description: 'Circular level badge — score + band + gradient-filled label. All rendered in code, no image assets.',
            child: _AppLevelBadgeDemo(),
          ),
          _ComponentSection(
            name: 'AppCheckbox',
            description: 'Filled `secondary` when checked, outlined when unchecked. Label to the right.',
            child: _AppCheckboxDemo(),
          ),
          _ComponentSection(
            name: 'AppRadioCard',
            description: 'Card-shaped radio option. Selected card gets the gold-highlight AppCard treatment.',
            child: _AppRadioCardDemo(),
          ),
          _ComponentSection(
            name: 'AppStarRating',
            description: 'Custom-painted 5-star rating. Filled=secondary, empty=alternate. onChanged=null → read-only.',
            child: _AppStarRatingDemo(),
          ),
          _ComponentSection(
            name: 'AppAudioNote',
            description: 'Voice note recorder + player. Visual/state-machine only for now — real audio wired when assessment feature lands.',
            child: _AppAudioNoteDemo(),
          ),
          _ComponentSection(
            name: 'AppSheet',
            description: 'Sheet shell (blurred backdrop, drag handle, rounded top) + AppSheetHeader (title, optional subtitle, close)',
            child: _AppSheetDemo(),
          ),
          _ComponentSection(
            name: 'AppFeedbackListItem (features/assessments)',
            description: 'Feedback / assessment row. Primitive props for now — feature wrapper (later) will map from Assessment model.',
            child: _AppFeedbackListItemDemo(),
          ),
          _ComponentSection(
            name: 'AppTextField',
            description: 'Text input. Optional label + leading icon. Clear button auto-shown when text present. States: default / focused / disabled / error.',
            child: _AppTextFieldDemo(),
          ),
          _ComponentSection(
            name: 'AppSelectTrigger',
            description: 'Input-shaped tappable trigger — chevron-down on right. Use for opening a sheet or menu. Same visual formula as AppTextField.',
            child: _AppSelectTriggerDemo(),
          ),
          _ComponentSection(
            name: 'AppLogo',
            description: 'Brand mark. Two sizes only via enum — `header` (top-left of onboarding) and `hero` (entry screen). No color prop.',
            child: _AppLogoDemo(),
          ),
          _ComponentSection(
            name: 'AppOnboardingHeader',
            description: 'Logo top-left + title + optional subtitle. Standard for onboarding pages. Pair with a transparent AppBar for the back button.',
            child: _AppOnboardingHeaderDemo(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Section shell + shared helpers
// ============================================================================

class _ComponentSection extends StatelessWidget {
  const _ComponentSection({
    required this.name,
    required this.description,
    required this.child,
  });

  final String name;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primaryText30, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTypography.titleMedium.copyWith(color: colors.primaryText)),
          const SizedBox(height: AppSpacing.xxs),
          Text(description, style: AppTypography.bodySmall.copyWith(color: colors.secondaryText)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// Wraps a demo widget with a small label below it so you can point at any
/// element and see what variant/size/state it is.
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.captionMedium.copyWith(color: colors.secondaryText),
        ),
      ],
    );
  }
}

Widget _sectionLabel(BuildContext context, String text) {
  final colors = context.colors;
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(
      text,
      style: AppTypography.captionSemibold.copyWith(
        color: colors.secondaryText,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ============================================================================
// AppAvatar demo
// ============================================================================

class _AppAvatarDemo extends StatelessWidget {
  const _AppAvatarDemo();

  static const _demoImageUrl = 'https://i.pravatar.cc/300?img=12';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('image', (size) => AppAvatar(imageUrl: _demoImageUrl, size: size)),
        const SizedBox(height: AppSpacing.md),
        _row('initials', (size) => const AppAvatar(firstName: 'John', lastName: 'Doe')),
        const SizedBox(height: AppSpacing.md),
        _row('icon', (size) => AppAvatar(size: size)),
      ],
    );
  }

  Widget _row(String stateLabel, Widget Function(AppAvatarSize) builder) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, stateLabel.toUpperCase()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Labeled(label: 'sm', child: builder(AppAvatarSize.small)),
              const SizedBox(width: AppSpacing.md),
              _Labeled(label: 'md', child: builder(AppAvatarSize.medium)),
              const SizedBox(width: AppSpacing.md),
              _Labeled(label: 'lg', child: builder(AppAvatarSize.large)),
            ],
          ),
        ],
      );
    });
  }
}

// ============================================================================
// AppButton demo
// ============================================================================

class _AppButtonDemo extends StatelessWidget {
  const _AppButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'VARIANTS'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'primary', child: AppButton(label: 'Press', onPressed: () {})),
            _Labeled(label: 'secondary', child: AppButton(label: 'Press', onPressed: () {}, variant: AppButtonVariant.secondary)),
            _Labeled(label: 'outline', child: AppButton(label: 'Press', onPressed: () {}, variant: AppButtonVariant.outline)),
            _Labeled(label: 'text', child: AppButton(label: 'Press', onPressed: () {}, variant: AppButtonVariant.text)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'SIZES'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _Labeled(label: 'large', child: AppButton(label: 'Press', onPressed: () {}, size: AppButtonSize.large)),
            _Labeled(label: 'medium', child: AppButton(label: 'Press', onPressed: () {}, size: AppButtonSize.medium)),
            _Labeled(label: 'small', child: AppButton(label: 'Press', onPressed: () {}, size: AppButtonSize.small)),
            _Labeled(label: 'xs', child: AppButton(label: 'Press', onPressed: () {}, size: AppButtonSize.xs)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'ICONS'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(
              label: 'leading',
              child: AppButton(label: 'Add', onPressed: () {}, size: AppButtonSize.medium, leadingIcon: AppIcons.plus),
            ),
            _Labeled(
              label: 'trailing',
              child: AppButton(label: 'Next', onPressed: () {}, size: AppButtonSize.medium, trailingIcon: AppIcons.arrowRight),
            ),
            _Labeled(
              label: 'both',
              child: AppButton(label: 'Item', onPressed: () {}, size: AppButtonSize.medium, leadingIcon: AppIcons.plus, trailingIcon: AppIcons.arrowRight),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'DISABLED'),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'primary', child: AppButton(label: 'Press', onPressed: null, size: AppButtonSize.medium)),
            _Labeled(label: 'secondary', child: AppButton(label: 'Press', onPressed: null, variant: AppButtonVariant.secondary, size: AppButtonSize.medium)),
            _Labeled(label: 'outline', child: AppButton(label: 'Press', onPressed: null, variant: AppButtonVariant.outline, size: AppButtonSize.medium)),
            _Labeled(label: 'text', child: AppButton(label: 'Press', onPressed: null, variant: AppButtonVariant.text, size: AppButtonSize.medium)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'LOADING'),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'primary', child: AppButton(label: 'Press', onPressed: null, size: AppButtonSize.medium, loading: true)),
            _Labeled(label: 'secondary', child: AppButton(label: 'Press', onPressed: null, variant: AppButtonVariant.secondary, size: AppButtonSize.medium, loading: true)),
            _Labeled(label: 'outline', child: AppButton(label: 'Press', onPressed: null, variant: AppButtonVariant.outline, size: AppButtonSize.medium, loading: true)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'EXPAND (full width)'),
        AppButton(
          label: 'Request Quick Feedback',
          onPressed: () {},
          variant: AppButtonVariant.outline,
          expand: true,
        ),
      ],
    );
  }
}

// ============================================================================
// AppIconButton demo
// ============================================================================

class _AppIconButtonDemo extends StatelessWidget {
  const _AppIconButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'VARIANTS'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'primary', child: AppIconButton(icon: AppIcons.plus, onPressed: () {}, variant: AppIconButtonVariant.primary)),
            _Labeled(label: 'secondary', child: AppIconButton(icon: AppIcons.plus, onPressed: () {}, variant: AppIconButtonVariant.secondary)),
            _Labeled(label: 'outline', child: AppIconButton(icon: AppIcons.plus, onPressed: () {}, variant: AppIconButtonVariant.outline)),
            _Labeled(label: 'ghost', child: AppIconButton(icon: AppIcons.plus, onPressed: () {})),
            _Labeled(label: 'tinted (default)', child: AppIconButton(icon: AppIcons.plus, onPressed: () {}, variant: AppIconButtonVariant.tinted)),
            _Labeled(
              label: 'tinted (error)',
              child: Builder(builder: (context) {
                return AppIconButton(
                  icon: AppIcons.stopFilled,
                  onPressed: () {},
                  variant: AppIconButtonVariant.tinted,
                  tintColor: context.colors.error,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'SIZES'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _Labeled(label: 'large', child: AppIconButton(icon: AppIcons.bell, onPressed: () {}, size: AppIconButtonSize.large)),
            _Labeled(label: 'medium', child: AppIconButton(icon: AppIcons.bell, onPressed: () {}, size: AppIconButtonSize.medium)),
            _Labeled(label: 'small', child: AppIconButton(icon: AppIcons.bell, onPressed: () {}, size: AppIconButtonSize.small)),
            _Labeled(label: 'xs', child: AppIconButton(icon: AppIcons.bell, onPressed: () {}, size: AppIconButtonSize.xs)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'DISABLED'),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'primary', child: AppIconButton(icon: AppIcons.plus, onPressed: null, variant: AppIconButtonVariant.primary)),
            _Labeled(label: 'secondary', child: AppIconButton(icon: AppIcons.plus, onPressed: null, variant: AppIconButtonVariant.secondary)),
            _Labeled(label: 'outline', child: AppIconButton(icon: AppIcons.plus, onPressed: null, variant: AppIconButtonVariant.outline)),
            _Labeled(label: 'ghost', child: AppIconButton(icon: AppIcons.plus, onPressed: null)),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// AppCard demo
// ============================================================================

class _AppCardDemo extends StatelessWidget {
  const _AppCardDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'PLAIN'),
        AppCard(
          child: Text(
            'plain — 2px alternate border',
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'UNREAD'),
        AppCard(
          variant: AppCardVariant.unread,
          child: Text(
            'unread — 2px link (blue) border',
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'FEATURED (default 1px)'),
        AppCard(
          variant: AppCardVariant.featured,
          child: Text(
            'featured — gold border + gradient, 1px (for use in toggle groups etc.)',
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'FEATURED + PROMINENT (2px hero)'),
        AppCard(
          variant: AppCardVariant.featured,
          prominent: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'featured + prominent',
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '2px gold border. Reserve for standalone hero cards.',
                style: AppTypography.bodySmall.copyWith(color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// AppIconIndicator demo (display-only)
// ============================================================================

class _AppIconIndicatorDemo extends StatelessWidget {
  const _AppIconIndicatorDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'MEDIUM (default, 48px)'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'error', child: AppIconIndicator(icon: AppIcons.bell, color: colors.error)),
            _Labeled(label: 'success', child: AppIconIndicator(icon: AppIcons.check, color: colors.success)),
            _Labeled(label: 'secondary', child: AppIconIndicator(icon: AppIcons.settings, color: colors.secondary)),
            _Labeled(label: 'link', child: AppIconIndicator(icon: AppIcons.chevronRight, color: colors.link)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'SMALL (32px, list-row use)'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(label: 'error', child: AppIconIndicator(icon: AppIcons.bell, color: colors.error, size: AppIconIndicatorSize.small)),
            _Labeled(label: 'success', child: AppIconIndicator(icon: AppIcons.check, color: colors.success, size: AppIconIndicatorSize.small)),
            _Labeled(label: 'secondary', child: AppIconIndicator(icon: AppIcons.settings, color: colors.secondary, size: AppIconIndicatorSize.small)),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// AppGameResultBadge demo
// ============================================================================

class _AppGameResultBadgeDemo extends StatelessWidget {
  const _AppGameResultBadgeDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _Labeled(label: 'win', child: AppGameResultBadge(result: GameResult.win)),
        _Labeled(label: 'loss', child: AppGameResultBadge(result: GameResult.loss)),
        _Labeled(label: 'tie', child: AppGameResultBadge(result: GameResult.tie)),
      ],
    );
  }
}

// ============================================================================
// AppLevelBadge demo
// ============================================================================

class _AppLevelBadgeDemo extends StatelessWidget {
  const _AppLevelBadgeDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        AppLevelBadge(score: 39, band: LevelBand.beginner),
        AppLevelBadge(score: 50, band: LevelBand.bronze),
        AppLevelBadge(score: 65, band: LevelBand.silver),
        AppLevelBadge(score: 80, band: LevelBand.gold),
        AppLevelBadge(score: 92, band: LevelBand.elite),
      ],
    );
  }
}

// ============================================================================
// AppCheckbox demo (stateful — user can actually toggle)
// ============================================================================

class _AppCheckboxDemo extends StatefulWidget {
  const _AppCheckboxDemo();

  @override
  State<_AppCheckboxDemo> createState() => _AppCheckboxDemoState();
}

class _AppCheckboxDemoState extends State<_AppCheckboxDemo> {
  final Set<String> _selected = {'AA'};

  @override
  Widget build(BuildContext context) {
    const levels = ['A', 'AA', 'AAA'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'LEVEL CLASSIFICATIONS (interactive)'),
        for (final level in levels) ...[
          AppCheckbox(
            label: 'Level $level',
            value: _selected.contains(level),
            onChanged: (v) => setState(() {
              if (v) {
                _selected.add(level);
              } else {
                _selected.remove(level);
              }
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),
        _sectionLabel(context, 'DISABLED'),
        const AppCheckbox(label: 'Disabled unchecked', value: false, onChanged: null),
        const SizedBox(height: AppSpacing.sm),
        const AppCheckbox(label: 'Disabled checked', value: true, onChanged: null),
      ],
    );
  }
}

// ============================================================================
// AppRadioCard demo (stateful group)
// ============================================================================

class _AppRadioCardDemo extends StatefulWidget {
  const _AppRadioCardDemo();

  @override
  State<_AppRadioCardDemo> createState() => _AppRadioCardDemoState();
}

class _AppRadioCardDemoState extends State<_AppRadioCardDemo> {
  String _selected = 'jesse';

  @override
  Widget build(BuildContext context) {
    const options = [
      (id: 'jesse', title: 'Coach Jesse', subtitle: 'Head Coach · Rampage'),
      (id: 'john', title: 'Coach John', subtitle: 'Skills Coach · Rampage'),
      (id: 'hank', title: 'Coach Hank', subtitle: 'Head Coach · Montana Jays'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'COACH SELECTION (interactive)'),
        for (final o in options) ...[
          AppRadioCard(
            title: o.title,
            subtitle: o.subtitle,
            selected: _selected == o.id,
            onTap: () => setState(() => _selected = o.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

// ============================================================================
// AppStarRating demo (stateful — interactive)
// ============================================================================

class _AppStarRatingDemo extends StatefulWidget {
  const _AppStarRatingDemo();

  @override
  State<_AppStarRatingDemo> createState() => _AppStarRatingDemoState();
}

class _AppStarRatingDemoState extends State<_AppStarRatingDemo> {
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'INTERACTIVE (tap stars)'),
        AppStarRating(value: _rating, onChanged: (v) => setState(() => _rating = v)),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'READ-ONLY'),
        for (final v in [1, 2, 3, 4, 5]) ...[
          Row(children: [
            SizedBox(
              width: 100,
              child: Text('$v of 5', style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText)),
            ),
            AppStarRating(value: v),
          ]),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

// ============================================================================
// AppAudioNote demo (stateful — recorder in idle, playback with fake url)
// ============================================================================

class _AppAudioNoteDemo extends StatelessWidget {
  const _AppAudioNoteDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'RECORDER (idle → recording → complete)'),
        const AppAudioNote(),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'PLAYBACK-ONLY (audioUrl provided)'),
        const AppAudioNote(audioUrl: 'https://example.com/demo.m4a'),
      ],
    );
  }
}

// ============================================================================
// AppSheet demo
// ============================================================================

class _AppSheetDemo extends StatelessWidget {
  const _AppSheetDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'SHOW'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _Labeled(
              label: 'title only',
              child: AppButton(
                label: 'Show sheet',
                onPressed: () => _showTitleOnlySheet(context),
                variant: AppButtonVariant.outline,
                size: AppButtonSize.medium,
              ),
            ),
            _Labeled(
              label: 'with subtitle',
              child: AppButton(
                label: 'Show sheet',
                onPressed: () => _showTitleSubtitleSheet(context),
                variant: AppButtonVariant.outline,
                size: AppButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTitleOnlySheet(BuildContext context) {
    showAppSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(title: 'Filter Feedback'),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Sheet body content goes here.',
              style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  void _showTitleSubtitleSheet(BuildContext context) {
    showAppSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(
            title: 'How It Works',
            subtitle: 'A quick walkthrough of scoring and feedback',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Sheet body content goes here.',
              style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AppTextField demo (stateful — real input)
// ============================================================================

class _AppTextFieldDemo extends StatefulWidget {
  const _AppTextFieldDemo();

  @override
  State<_AppTextFieldDemo> createState() => _AppTextFieldDemoState();
}

class _AppTextFieldDemoState extends State<_AppTextFieldDemo> {
  final _defaultCtrl = TextEditingController();
  final _prefilledCtrl = TextEditingController(text: 'Typing someth');
  final _errorCtrl = TextEditingController(text: 'Value');

  @override
  void dispose() {
    _defaultCtrl.dispose();
    _prefilledCtrl.dispose();
    _errorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Default Input',
          placeholder: 'Placeholder',
          controller: _defaultCtrl,
          leadingIcon: AppIcons.userFallback,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Prefilled (tap to focus)',
          controller: _prefilledCtrl,
          leadingIcon: AppIcons.userFallback,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Disabled Input',
          placeholder: 'Unable to select',
          enabled: false,
          leadingIcon: AppIcons.userFallback,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Error Input',
          controller: _errorCtrl,
          leadingIcon: AppIcons.userFallback,
          errorText: 'This field has an error',
        ),
      ],
    );
  }
}

// ============================================================================
// AppSelectTrigger demo
// ============================================================================

class _AppSelectTriggerDemo extends StatefulWidget {
  const _AppSelectTriggerDemo();

  @override
  State<_AppSelectTriggerDemo> createState() => _AppSelectTriggerDemoState();
}

class _AppSelectTriggerDemoState extends State<_AppSelectTriggerDemo> {
  String? _pickedRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSelectTrigger(
          label: 'Please Select',
          placeholder: 'Choose a role',
          value: _pickedRole,
          leadingIcon: AppIcons.userFallback,
          onTap: () => _showRolePicker(context),
        ),
        const SizedBox(height: AppSpacing.md),
        AppSelectTrigger(
          label: 'Disabled Select',
          placeholder: 'Unable to select',
          leadingIcon: AppIcons.userFallback,
          onTap: null,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSelectTrigger(
          label: 'Error Select',
          placeholder: 'Choose a role',
          value: 'Value',
          leadingIcon: AppIcons.userFallback,
          errorText: 'This selection has an error',
          onTap: () {},
        ),
      ],
    );
  }

  void _showRolePicker(BuildContext ctx) {
    showAppSheet(
      context: ctx,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHeader(title: 'Choose a role'),
          for (final r in ['Athlete', 'Coach', 'General Manager']) ...[
            ListTile(
              title: Text(r, style: AppTypography.bodyLarge.copyWith(color: sheetCtx.colors.primaryText)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                setState(() => _pickedRole = r);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ============================================================================
// AppFeedbackListItem demo (features/assessments)
// ============================================================================

class _AppFeedbackListItemDemo extends StatelessWidget {
  const _AppFeedbackListItemDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFeedbackListItem(
          coachName: 'Coach John',
          coachRole: 'Head Coach · Rampage U13 AAA',
          timeAgo: '1d ago',
          indicatorIcon: AppIcons.check,
          indicatorColor: colors.secondary,
          body: 'Quick Feedback Submitted',
          unread: true,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        AppFeedbackListItem(
          coachName: 'Coach John',
          coachRole: 'Head Coach · Rampage U13 AAA',
          timeAgo: '1d ago',
          indicatorIcon: AppIcons.check,
          indicatorColor: colors.secondary,
          body: 'Quick Feedback Submitted',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        AppFeedbackListItem(
          coachName: 'Coach John',
          coachRole: 'Head Coach · Rampage U13 AAA',
          timeAgo: '1d ago',
          indicatorIcon: AppIcons.checkCircle,
          indicatorColor: colors.success,
          body: 'Formal Assessment Completed',
          onTap: () {},
        ),
      ],
    );
  }
}

class _AppLogoDemo extends StatelessWidget {
  const _AppLogoDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppLogo(size: AppLogoSize.header),
        AppLogo(size: AppLogoSize.hero),
      ],
    );
  }
}

class _AppOnboardingHeaderDemo extends StatelessWidget {
  const _AppOnboardingHeaderDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppOnboardingHeader(
          title: 'Welcome',
          subtitle: 'Select your user type to begin creating your account.',
        ),
        SizedBox(height: AppSpacing.xl),
        AppOnboardingHeader(title: 'No subtitle example'),
      ],
    );
  }
}
