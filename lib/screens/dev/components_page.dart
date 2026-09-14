import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/app_audio_note.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_checkbox.dart';
import '../../shared/widgets/app_divider.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_game_result_badge.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_icon_indicator.dart';
import '../../shared/widgets/app_level_badge.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_onboarding_header.dart';
import '../../shared/widgets/app_player_passport_card.dart';
import '../../shared/widgets/app_profile_header.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_radio_card.dart';
import '../../shared/widgets/app_score_bar.dart';
import '../../shared/widgets/app_tab_bar.dart';
import '../../features/assessments/ui/widgets/app_feedback_list_item.dart';
import '../../features/assessments/ui/widgets/score_gauge.dart';
import '../../features/team/ui/widgets/external_connection_row.dart';
import '../../features/team/ui/widgets/game_result_row.dart';
import '../../features/team/ui/widgets/roster_row.dart';
import '../../features/team/ui/widgets/stat_card.dart';
import '../../features/team/ui/widgets/team_header.dart';
import '../../features/team/ui/widgets/todo_row.dart';
import '../../features/team/ui/widgets/upcoming_game_card.dart';
import '../../generated/api/get_assessments.dart';
import '../../generated/api/get_games.dart';
import '../../generated/api/get_profile.dart' as profile_api;
import '../../generated/api/get_team_roster.dart' as roster;
import '../../shared/widgets/app_select_trigger.dart';
import '../../shared/widgets/app_sheet_layout.dart';
import '../../shared/widgets/app_sheet_shell.dart';
import '../../shared/widgets/app_star_rating.dart';
import '../../shared/widgets/app_text_badge.dart';
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
            name: 'AppTextBadge',
            description: 'Small pill with a color + uppercase label. Same visual formula as AppGameResultBadge but primitive props — use for WIN/LOSS/TIE, NEW, LIVE, VERIFIED, etc. Two sizes: small (list rows) and medium (card contexts).',
            child: _AppTextBadgeDemo(),
          ),
          _ComponentSection(
            name: 'AppDivider',
            description: 'Standard 1px horizontal rule in colors.alternate. Use everywhere you need a divider so color + thickness stay consistent.',
            child: _AppDividerDemo(),
          ),
          _ComponentSection(
            name: 'AppLevelHeroBadge',
            description: 'Large presentational badge — hero coin PNG + gradient-masked band name below. Fixed 160×160 coin.',
            child: _AppLevelHeroBadgeDemo(),
          ),
          _ComponentSection(
            name: 'AppLevelCoin',
            description: 'Small coin PNG with sub-level (I/II/III) baked in. Fixed 72×72. Beginner has only sub-level 1; others accept 1–3.',
            child: _AppLevelCoinDemo(),
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
            name: 'AppTabBar',
            description: 'Horizontally-scrollable underline tab bar. Active tab: bold `primaryText` + `secondary`-colored underline. Inactive: `secondaryText`, no underline.',
            child: _AppTabBarDemo(),
          ),
          _ComponentSection(
            name: 'AppChip',
            description: 'Selectable filter pill. Selected: `link`-tint background + `link` border + primary text. Unselected: transparent + `alternate` border + secondary text. Fires selection haptic on tap.',
            child: _AppChipDemo(),
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
            name: 'TodoRow (features/team)',
            description: 'Actionable to-do row used on coach dashboard surfaces (Games, Home). Composes AppIconIndicator + title/subtitle + chevron; fires light haptic on tap. Feature-scoped for now.',
            child: _TodoRowDemo(),
          ),
          _ComponentSection(
            name: 'UpcomingGameCard (features/team)',
            description: 'Compact card for a scheduled future game. Blue outline via AppCardVariant.unread. Fixed-width so it sits nicely in a horizontal scroller.',
            child: _UpcomingGameCardDemo(),
          ),
          _ComponentSection(
            name: 'GameResultRow (features/team)',
            description: 'List row for a completed game — coach Games Results section. Composes AppGameResultBadge; derives W/L/T from scores; formats date and vs/@ prefix from the Game model.',
            child: _GameResultRowDemo(),
          ),
          _ComponentSection(
            name: 'TeamHeader (features/team)',
            description: 'Team hero card shown on Team pages (athlete + coach) and later coach Home. Featured + prominent AppCard with team crest, uppercase name, and composed subtitle (age + level, joined with " · ").',
            child: _TeamHeaderDemo(),
          ),
          _ComponentSection(
            name: 'StatCard (features/team)',
            description: 'Small stat tile used in a horizontal row on Team pages — uppercase label above headline value. `accent: true` for the marquee stat (RANKING) styles the value gold.',
            child: _StatCardDemo(),
          ),
          _ComponentSection(
            name: 'RosterRow (features/team)',
            description: 'Coach Team page roster row. Avatar + name + subtitle (position · band label) + AppLevelCoin. Handles the null-ranking case (unassessed athletes) by preserving layout with a coin-sized spacer.',
            child: _RosterRowDemo(),
          ),
          _ComponentSection(
            name: 'ExternalConnectionRow (features/team)',
            description: 'Coach Team page External Connections row. Avatar + name + subtitle (position · linked-team-name in blue) + AppLevelCoin. Ranking coin reflects the athlete\'s current-team level. Handles null current-team (no team) with "-".',
            child: _ExternalConnectionRowDemo(),
          ),
          _ComponentSection(
            name: 'ScoreGauge (features/assessments)',
            description: 'Formal-assessment score visual — colored badge + gradient band bar with pointer at score/max. Score bands (beginner→elite) drive the badge color; the bar gradient is fixed regardless of score so the pointer reads as position on the ladder.',
            child: _ScoreGaugeDemo(),
          ),
          _ComponentSection(
            name: 'AppScoreBar',
            description: 'Shared score-visualization bar used by the DVLP skills list (band, no pointer) and the ScoreGauge (band, with pointer). Two fills: `band` shows the full beginner→elite gradient (position conveyed by pointer or adjacent readout); `flat` shows a single-tone fill that fills to `fraction × width`. Ticks at each interior whole-number step regardless of fill.',
            child: _AppScoreBarDemo(),
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
          _ComponentSection(
            name: 'AppProfileHeader',
            description: 'Featured + prominent AppCard with avatar, uppercase Anybody 24 title, and optional subtitle. Initials fall back from title. Primitive props — map from Profile at the call site.',
            child: _AppProfileHeaderDemo(),
          ),
          _ComponentSection(
            name: 'AppPlayerPassportCard',
            description: 'Featured+prominent passport identity card — avatar row on top, 5-column stats grid (Age / Height / Weight / Hand / Verified). Primitive strings only; verified is stubbed as "-" until the verification feature lands.',
            child: _AppPlayerPassportCardDemo(),
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

class _AppTextBadgeDemo extends StatelessWidget {
  const _AppTextBadgeDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'SMALL (default, list rows)'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppTextBadge(label: 'Win', color: colors.success),
            AppTextBadge(label: 'Loss', color: colors.error),
            AppTextBadge(label: 'Tie', color: colors.link),
            AppTextBadge(label: 'New', color: colors.secondary),
            AppTextBadge(label: 'Live', color: colors.error),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'MEDIUM (hero on cards)'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppTextBadge(label: 'Win', color: colors.success, size: AppTextBadgeSize.medium),
            AppTextBadge(label: 'Loss', color: colors.error, size: AppTextBadgeSize.medium),
            AppTextBadge(label: 'Tie', color: colors.link, size: AppTextBadgeSize.medium),
          ],
        ),
      ],
    );
  }
}

class _AppDividerDemo extends StatelessWidget {
  const _AppDividerDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Above', style: AppTypography.bodyMedium.copyWith(color: colors.primaryText)),
        const SizedBox(height: AppSpacing.md),
        const AppDivider(),
        const SizedBox(height: AppSpacing.md),
        Text('Below', style: AppTypography.bodyMedium.copyWith(color: colors.primaryText)),
      ],
    );
  }
}

// ============================================================================
// AppLevelHeroBadge demo — one hero per band
// ============================================================================

class _AppLevelHeroBadgeDemo extends StatelessWidget {
  const _AppLevelHeroBadgeDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      alignment: WrapAlignment.center,
      children: [
        AppLevelHeroBadge(band: LevelBand.beginner),
        AppLevelHeroBadge(band: LevelBand.bronze),
        AppLevelHeroBadge(band: LevelBand.silver),
        AppLevelHeroBadge(band: LevelBand.gold),
        AppLevelHeroBadge(band: LevelBand.elite),
      ],
    );
  }
}

// ============================================================================
// AppLevelCoin demo — full grid: 5 bands × sub-levels (beginner=1, others=1..3)
// ============================================================================

class _AppLevelCoinDemo extends StatelessWidget {
  const _AppLevelCoinDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final band in LevelBand.values) ...[
          _sectionLabel(context, band.name.toUpperCase()),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final n in band == LevelBand.beginner ? const [1] : const [1, 2, 3])
                _Labeled(label: 'sub $n', child: AppLevelCoin(band: band, subLevel: n)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
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
// AppTabBar demo (stateful — interactive)
// ============================================================================

class _AppTabBarDemo extends StatefulWidget {
  const _AppTabBarDemo();

  @override
  State<_AppTabBarDemo> createState() => _AppTabBarDemoState();
}

class _AppTabBarDemoState extends State<_AppTabBarDemo> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      labels: const ['Chapter 1 - A', 'Chapter 2 - AA', 'Chapter 3 - AAA'],
      currentIndex: _selected,
      onTap: (i) => setState(() => _selected = i),
    );
  }
}

// ============================================================================
// AppChip demo (stateful — interactive)
// ============================================================================

class _AppChipDemo extends StatefulWidget {
  const _AppChipDemo();

  @override
  State<_AppChipDemo> createState() => _AppChipDemoState();
}

class _AppChipDemoState extends State<_AppChipDemo> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    const options = ['All', 'Rampage U11 A', 'Rampage U12 A'];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: options[i],
              // First option ("All") = null selection state.
              selected: (i == 0 && _selected == null) || _selected == options[i],
              onTap: () => setState(() => _selected = i == 0 ? null : options[i]),
            ),
          ],
        ],
      ),
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
      builder: (context) => AppSheetLayout(
        title: 'Filter Feedback',
        child: Text(
          'Sheet body content goes here.',
          style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText),
        ),
      ),
    );
  }

  void _showTitleSubtitleSheet(BuildContext context) {
    showAppSheet(
      context: context,
      builder: (context) => AppSheetLayout(
        title: 'How It Works',
        subtitle: 'A quick walkthrough of scoring and feedback',
        child: Text(
          'Sheet body content goes here.',
          style: AppTypography.bodyMedium.copyWith(color: context.colors.secondaryText),
        ),
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
      builder: (sheetCtx) => AppSheetLayout(
        title: 'Choose a role',
        bodyPadding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in ['Athlete', 'Coach', 'General Manager'])
              ListTile(
                title: Text(r, style: AppTypography.bodyLarge.copyWith(color: sheetCtx.colors.primaryText)),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  setState(() => _pickedRole = r);
                },
              ),
          ],
        ),
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
    final quickRecent = _mockAssessment(
      type: AssessmentType.QUICK,
      hoursAgo: 18,
    );
    final quickOlder = _mockAssessment(
      type: AssessmentType.QUICK,
      hoursAgo: 24 * 3,
    );
    final formalOlder = _mockAssessment(
      type: AssessmentType.FORMAL,
      hoursAgo: 24 * 5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFeedbackListItem(assessment: quickRecent, unread: true, onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        AppFeedbackListItem(assessment: quickOlder, onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        AppFeedbackListItem(assessment: formalOlder, onTap: () {}),
      ],
    );
  }

  static Assessment _mockAssessment({
    required AssessmentType type,
    required int hoursAgo,
    bool athleteRead = false,
  }) {
    return Assessment(
      id: '00000000-0000-0000-0000-000000000000',
      assessmentType: type,
      weightedRole: WeightedRole.HEAD_COACH,
      submittedAt: DateTime.now().subtract(Duration(hours: hoursAgo)).toIso8601String(),
      athleteRead: athleteRead,
      accessScope: AccessScope.TEAM,
      coach: Coach(
        id: '00000000-0000-0000-0000-000000000001',
        firstName: 'Jesse',
        lastName: 'Coach',
        avatarUrl: null,
      ),
      team: Team(
        id: '00000000-0000-0000-0000-000000000002',
        name: 'Rampage U13',
        ageGroup: 'U13',
        levelClassification: LevelClassification(
          id: '00000000-0000-0000-0000-000000000003',
          name: 'AAA',
          tierOrder: 3,
        ),
      ),
    );
  }
}

class _ScoreGaugeDemo extends StatelessWidget {
  const _ScoreGaugeDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreGauge(
          title: 'Speed',
          description: 'Straight-line acceleration and top speed',
          score: 7.5,
          maxScore: 10,
          previousScore: 4,
        ),
        SizedBox(height: AppSpacing.xl),
        ScoreGauge(
          title: 'Edges',
          description: 'Turns, pivots, transitions, balance',
          score: 9,
          maxScore: 10,
          previousScore: 4,
        ),
        SizedBox(height: AppSpacing.xl),
        ScoreGauge(
          title: 'Stick Handling',
          description: 'Puck control in motion and in traffic',
          score: 8,
          maxScore: 10,
          previousScore: 4,
        ),
        SizedBox(height: AppSpacing.xl),
        ScoreGauge(
          title: 'Defense',
          description: 'Gap control, positioning, stick work',
          score: 5.5,
          maxScore: 10,
          previousScore: 4,
        ),
      ],
    );
  }
}

class _AppScoreBarDemo extends StatelessWidget {
  const _AppScoreBarDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Band, no pointer (DVLP skill row)',
          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        const AppScoreBar(fraction: 0.75, tickCount: 9, fill: AppScoreBarFill.band),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Band, with pointer, taller (ScoreGauge)',
          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        const AppScoreBar(
          fraction: 0.55,
          tickCount: 9,
          fill: AppScoreBarFill.band,
          showPointer: true,
          height: 8,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Flat, secondary fill (default)',
          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        const AppScoreBar(fraction: 0.40, tickCount: 9),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Flat, custom fill color',
          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppScoreBar(
          fraction: 0.85,
          tickCount: 9,
          flatFillColor: colors.success,
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
        AppLogo(size: AppLogoSize.medium),
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

class _AppProfileHeaderDemo extends StatelessWidget {
  const _AppProfileHeaderDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'WITH SUBTITLE (initials fallback)'),
        const AppProfileHeader(
          title: 'Test Athlete',
          subtitle: 'Rampage U13',
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'TITLE ONLY'),
        const AppProfileHeader(title: 'Test Athlete'),
        const SizedBox(height: AppSpacing.md),
        _sectionLabel(context, 'WITH AVATAR URL'),
        const AppProfileHeader(
          title: 'John Doe',
          subtitle: 'Head Coach · Rampage',
          avatarUrl: 'https://i.pravatar.cc/300?img=12',
        ),
      ],
    );
  }
}

class _AppPlayerPassportCardDemo extends StatelessWidget {
  const _AppPlayerPassportCardDemo();

  @override
  Widget build(BuildContext context) {
    // Match how the passport page composes it — coin visual center
    // sits on the card top edge; PNG label baked inside the card's
    // reserved topInset.
    const heroDim = AppLevelHeroBadge.dim;
    const coinVisualCenterFraction = 0.5;
    const cardOffset = heroDim * coinVisualCenterFraction;
    const cardTopInset = heroDim - cardOffset;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: cardOffset),
          child: AppPlayerPassportCard(
            firstName: 'Marcus',
            lastName: 'Thompson',
            teamLine: 'Rampage U13 AAA | Forward',
            age: '14 yo',
            height: "5'9\"",
            weight: '145lbs',
            hand: 'Right',
            verified: '-',
            avatarUrl: 'https://i.pravatar.cc/300?img=12',
            topInset: cardTopInset,
          ),
        ),
        const AppLevelHeroBadge(band: LevelBand.silver),
      ],
    );
  }
}

class _TodoRowDemo extends StatelessWidget {
  const _TodoRowDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TodoRow(
          icon: AppIcons.coachNavGames,
          iconColor: colors.error,
          title: 'Post-game report pending',
          subtitle: 'vs Lakers · Feb 22',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        TodoRow(
          icon: AppIcons.award,
          iconColor: colors.success,
          title: '2 Formal Assessments due',
          subtitle: 'Timmy R., Blake W.',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        TodoRow(
          icon: AppIcons.messageQuestionSquare,
          iconColor: colors.secondary,
          title: '3 Quick Feedback Requests',
          subtitle: 'Timmy R., Blake W., Nate O.',
          onTap: () {},
        ),
      ],
    );
  }
}

class _UpcomingGameCardDemo extends StatelessWidget {
  const _UpcomingGameCardDemo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => UpcomingGameCard(
          game: _mockUpcoming(
            opponent: ['Sabers', 'Bruins', 'Rangers'][i],
            location: ['Riverside Arena', 'Central Rink', 'North Park'][i],
            daysFromNow: [1, 3, 7][i],
            isHome: [true, false, true][i],
          ),
          onTap: () {},
        ),
      ),
    );
  }

  static Game _mockUpcoming({
    required String opponent,
    required String location,
    required int daysFromNow,
    required bool isHome,
  }) {
    final at = DateTime.now().add(Duration(days: daysFromNow, hours: 10, minutes: 15));
    return Game(
      id: '00000000-0000-0000-0000-00000000000$daysFromNow',
      teamId: '00000000-0000-0000-0000-000000000000',
      opponentName: opponent,
      startsAt: at.toIso8601String(),
      location: location,
      isHome: isHome,
      teamScore: null,
      opponentScore: null,
      note: null,
      noteCoachId: null,
    );
  }
}

class _GameResultRowDemo extends StatelessWidget {
  const _GameResultRowDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GameResultRow(game: _mockResult(opponent: 'Lakers', team: 4, opp: 2, daysAgo: 5, isHome: true), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        GameResultRow(game: _mockResult(opponent: 'Sabres', team: 2, opp: 4, daysAgo: 12, isHome: false), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        GameResultRow(game: _mockResult(opponent: 'Rangers', team: 3, opp: 3, daysAgo: 19, isHome: true), onTap: () {}),
      ],
    );
  }

  static Game _mockResult({
    required String opponent,
    required int team,
    required int opp,
    required int daysAgo,
    required bool isHome,
  }) {
    final at = DateTime.now().subtract(Duration(days: daysAgo));
    return Game(
      id: '00000000-0000-0000-0000-00000000000$daysAgo',
      teamId: '00000000-0000-0000-0000-000000000000',
      opponentName: opponent,
      startsAt: at.toIso8601String(),
      location: null,
      isHome: isHome,
      teamScore: team,
      opponentScore: opp,
      note: null,
      noteCoachId: null,
    );
  }
}

class _TeamHeaderDemo extends StatelessWidget {
  const _TeamHeaderDemo();

  @override
  Widget build(BuildContext context) {
    return TeamHeader(
      team: profile_api.Team(
        id: '00000000-0000-0000-0000-000000000000',
        name: 'Rampage',
        ageGroup: 'U13',
        levelClassification: 'AAA',
        assessmentCadence: profile_api.AssessmentCadence.MONTHLY,
      ),
    );
  }
}

class _StatCardDemo extends StatelessWidget {
  const _StatCardDemo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: StatCard(label: 'RECORD', value: '8-3-1')),
        SizedBox(width: AppSpacing.md),
        Expanded(child: StatCard(label: 'RANKING', value: '2nd', accent: true)),
      ],
    );
  }
}

class _RosterRowDemo extends StatelessWidget {
  const _RosterRowDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RosterRow(entry: _mockEntry('Ethan',   'Callahan',  'Goalie',      roster.Band.GOLD,    3, 8.8), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        RosterRow(entry: _mockEntry('Marcus',  'Thompson',  'Defense',     roster.Band.GOLD,    1, 7.7), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        RosterRow(entry: _mockEntry('Nate',    'O\'Connor', 'Right Wing',  roster.Band.SILVER,  3, 7.3), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        RosterRow(entry: _mockEntry('Timmy',   'Reyes',     'Center',      roster.Band.BRONZE,  2, 4.9), onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        RosterRow(entry: _mockUnranked('Alex', 'Kim', 'Defense'), onTap: () {}),
      ],
    );
  }

  static roster.Roster _mockEntry(
    String first,
    String last,
    String position,
    roster.Band band,
    int subLevel,
    double score,
  ) {
    return roster.Roster(
      athlete: roster.RosterAthlete(
        id: '00000000-0000-0000-0000-000000000000',
        firstName: first,
        lastName: last,
        avatarUrl: null,
        position: roster.FluffyPosition(
          id: '00000000-0000-0000-0000-000000000000',
          name: position,
        ),
      ),
      ranking: roster.RosterRanking(
        overallScore: score,
        band: band,
        subLevel: subLevel,
        assessmentCount: 1,
      ),
    );
  }

  static roster.Roster _mockUnranked(String first, String last, String position) {
    return roster.Roster(
      athlete: roster.RosterAthlete(
        id: '00000000-0000-0000-0000-000000000000',
        firstName: first,
        lastName: last,
        avatarUrl: null,
        position: roster.FluffyPosition(
          id: '00000000-0000-0000-0000-000000000000',
          name: position,
        ),
      ),
      ranking: null,
    );
  }
}

class _ExternalConnectionRowDemo extends StatelessWidget {
  const _ExternalConnectionRowDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExternalConnectionRow(
          entry: _mockEntry(
            first: 'Test',
            last: 'Athlete',
            position: 'Right Wing',
            teamName: 'Rampage',
            ageGroup: 'U13',
            level: 'AAA',
            band: roster.Band.SILVER,
            subLevel: 3,
            score: 7.05,
          ),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        ExternalConnectionRow(
          entry: _mockEntry(
            first: 'Jordan',
            last: 'Reyes',
            position: 'Center',
            teamName: 'Markham Majors',
            ageGroup: 'U12',
            level: 'AA',
            band: roster.Band.BRONZE,
            subLevel: 2,
            score: 5.1,
          ),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        // No-team edge case (grant active but athlete left every team).
        ExternalConnectionRow(entry: _mockNoTeam(), onTap: () {}),
      ],
    );
  }

  static roster.ExternalConnection _mockEntry({
    required String first,
    required String last,
    required String position,
    required String teamName,
    required String ageGroup,
    required String level,
    required roster.Band band,
    required int subLevel,
    required double score,
  }) {
    return roster.ExternalConnection(
      athlete: roster.ExternalConnectionAthlete(
        id: '00000000-0000-0000-0000-000000000000',
        firstName: first,
        lastName: last,
        avatarUrl: null,
        position: roster.PurplePosition(
          id: '00000000-0000-0000-0000-000000000000',
          name: position,
        ),
      ),
      currentTeam: roster.CurrentTeam(
        id: '00000000-0000-0000-0000-000000000000',
        name: teamName,
        ageGroup: ageGroup,
        levelClassification: level,
      ),
      ranking: roster.ExternalConnectionRanking(
        overallScore: score,
        band: band,
        subLevel: subLevel,
        assessmentCount: 6,
      ),
    );
  }

  static roster.ExternalConnection _mockNoTeam() {
    return roster.ExternalConnection(
      athlete: roster.ExternalConnectionAthlete(
        id: '00000000-0000-0000-0000-000000000000',
        firstName: 'Casey',
        lastName: 'Nguyen',
        avatarUrl: null,
        position: roster.PurplePosition(
          id: '00000000-0000-0000-0000-000000000000',
          name: 'Defense',
        ),
      ),
      currentTeam: null,
      ranking: null,
    );
  }
}
