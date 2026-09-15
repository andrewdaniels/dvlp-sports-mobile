import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../features/auth/controllers/profile_providers.dart';
import '../../../features/auth/data/api_result.dart';
import '../../../features/team/controllers/games_providers.dart';
import '../../../features/team/controllers/team_roster_providers.dart';
import '../../../features/team/data/games_repository.dart';
import '../../../features/team/ui/sheets/athlete_selection_sheet.dart';
import '../../../generated/api/get_games.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_detail_app_bar.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_screen_footer.dart';
import '../../../shared/widgets/app_select_trigger.dart';
import '../../../shared/widgets/app_text_area.dart';
import '../../../shared/widgets/keyboard_dismissible.dart';

/// Coach-side game detail. Two modes based on the game's state:
///
///   • Played (scores set OR starts_at in past) → composer: editable
///     score row + optional notes + Publish/Update Report CTA. Past-
///     but-unscored games land here so the coach can fill in the
///     result. Publish/Update wording flips based on whether `note`
///     is already populated.
///   • Upcoming (no scores AND starts_at > now) → read-only preview
///     with an "Upcoming" indicator; no CTA (editing scheduled games
///     is a web-app feature per client roadmap).
///
/// Save flow follows the journal pattern (pessimistic): await server,
/// then targeted local mutation via [GamesNotifier.replaceGame] + pop.
/// Only dirty fields (current != initial) go into the update payload —
/// the server treats omitted keys as "don't touch" so a score-only
/// edit won't re-attribute an existing note.
///
/// Coach's active team resolves from currentProfileProvider's first
/// coach-scope membership (same lookup as CoachGamesPage). Multi-team
/// switcher lands with the multi-team coach flow.
class CoachGameDetailsPage extends ConsumerWidget {
  const CoachGameDetailsPage({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (_, _) => const Scaffold(body: SizedBox.shrink()),
      data: (profile) {
        final coachMembership = profile?.teamMemberships
            .where((m) => m.coachType != null)
            .firstOrNull;
        if (coachMembership == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        return _GameDetailsScaffold(
          gameId: gameId,
          teamId: coachMembership.team.id,
          teamName: coachMembership.team.name,
        );
      },
    );
  }
}

class _GameDetailsScaffold extends ConsumerWidget {
  const _GameDetailsScaffold({
    required this.gameId,
    required this.teamId,
    required this.teamName,
  });

  final String gameId;
  final String teamId;
  final String teamName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider(teamId));
    final games = gamesAsync.value?.games ?? const <Game>[];
    final game = games.where((g) => g.id == gameId).firstOrNull;

    if (game == null) {
      // Cache didn't have it — could be stale after a hot-restart or
      // navigating in via a direct URL. Show a loading state; the
      // provider fetches on watch, so the game will resolve.
      return Scaffold(
        appBar: AppDetailAppBar(title: _titleFor(game, teamName)),
        body: gamesAsync.isLoading
            ? const Center(child: AppLoadingIndicator())
            : const _NotFound(),
      );
    }

    // A game is ready for the composer once it's been played —
    // either scores are already set (edit an existing report) OR
    // the start time is in the past (enter scores for the first
    // time). Only truly future unscored games render the read-only
    // "upcoming" preview.
    final scored = game.teamScore != null && game.opponentScore != null;
    final startsAt = DateTime.tryParse(game.startsAt);
    final startedInPast =
        startsAt != null && !startsAt.isAfter(DateTime.now());
    final showComposer = scored || startedInPast;

    return Scaffold(
      appBar: AppDetailAppBar(
        title: _titleFor(game, teamName),
        subtitle: _subtitleFor(game),
      ),
      body: showComposer
          ? _ReportComposer(game: game, teamId: teamId, teamName: teamName)
          : _UpcomingPreview(game: game, teamName: teamName),
    );
  }

  static String _titleFor(Game? game, String teamName) {
    if (game == null) return 'Game';
    final prefix = game.isHome ? 'vs' : '@';
    return '$teamName $prefix ${game.opponentName}';
  }

  static String? _subtitleFor(Game game) {
    final at = DateTime.tryParse(game.startsAt)?.toLocal();
    final parts = <String>[
      if (at != null) _formatShortDate(at),
      if ((game.location ?? '').isNotEmpty) game.location!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

// ─── Post-game report composer (completed games) ───────────────────

class _ReportComposer extends ConsumerStatefulWidget {
  const _ReportComposer({
    required this.game,
    required this.teamId,
    required this.teamName,
  });

  final Game game;
  final String teamId;
  final String teamName;

  @override
  ConsumerState<_ReportComposer> createState() => _ReportComposerState();
}

class _ReportComposerState extends ConsumerState<_ReportComposer> {
  late final TextEditingController _teamScoreCtrl;
  late final TextEditingController _opponentScoreCtrl;
  late final TextEditingController _noteCtrl;

  // Initial values captured on load — dirty-tracking compares current
  // against these to build a minimal PATCH payload.
  late final int? _initialTeamScore;
  late final int? _initialOpponentScore;
  late final String _initialNote;
  late final Set<String> _initialStandouts;

  /// Live standouts selection. Sets rather than lists — order doesn't
  /// matter for the server (unranked) and lookup is faster.
  late Set<String> _standoutIds;

  /// Hard cap matches the design; server has no cap enforcement.
  /// Bump here if the client wants more.
  static const int _standoutsCap = 3;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialTeamScore = widget.game.teamScore;
    _initialOpponentScore = widget.game.opponentScore;
    _initialNote = widget.game.note ?? '';
    _initialStandouts = widget.game.standoutAthleteIds.toSet();
    _standoutIds = {..._initialStandouts};
    _teamScoreCtrl = TextEditingController(text: _initialTeamScore?.toString() ?? '');
    _opponentScoreCtrl = TextEditingController(text: _initialOpponentScore?.toString() ?? '');
    _noteCtrl = TextEditingController(text: _initialNote);
    _teamScoreCtrl.addListener(_rebuildOnChange);
    _opponentScoreCtrl.addListener(_rebuildOnChange);
    _noteCtrl.addListener(_rebuildOnChange);
  }

  @override
  void dispose() {
    _teamScoreCtrl.dispose();
    _opponentScoreCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _rebuildOnChange() {
    // Trigger a rebuild so the CTA enabled-state tracks dirty-ness in
    // real time as the coach types. Cheap — the page tree is small.
    if (mounted) setState(() {});
  }

  int? get _currentTeamScore => int.tryParse(_teamScoreCtrl.text.trim());
  int? get _currentOpponentScore => int.tryParse(_opponentScoreCtrl.text.trim());
  String get _currentNote => _noteCtrl.text;

  bool get _teamScoreDirty => _currentTeamScore != _initialTeamScore;
  bool get _opponentScoreDirty => _currentOpponentScore != _initialOpponentScore;
  bool get _noteDirty => _currentNote.trim() != _initialNote.trim();
  bool get _standoutsDirty =>
      _standoutIds.length != _initialStandouts.length ||
      !_standoutIds.containsAll(_initialStandouts);
  bool get _anyDirty =>
      _teamScoreDirty || _opponentScoreDirty || _noteDirty || _standoutsDirty;

  /// A report is "published" once the score is set. Note + standouts
  /// are optional, so their presence doesn't affect the CTA label —
  /// scoring is the publish action; everything else is enrichment.
  bool get _hasExistingReport =>
      _initialTeamScore != null && _initialOpponentScore != null;

  /// Opens the athlete picker sheet with the current roster + selection.
  /// Falls back to a small message if the roster hasn't loaded yet.
  Future<void> _openStandoutsSheet() async {
    final roster = ref.read(teamRosterProvider(widget.teamId)).value?.roster;
    if (roster == null || roster.isEmpty) {
      // No roster yet — either still loading or fetch failed. Silent
      // no-op; the trigger is visible either way. Coach can retry.
      return;
    }
    final items = [
      for (final r in roster)
        AthletePickerItem(
          id: r.athlete.id,
          firstName: r.athlete.firstName,
          lastName: r.athlete.lastName,
          avatarUrl: r.athlete.avatarUrl,
        ),
    ];
    final picked = await showAthleteSelectionSheet(
      context: context,
      title: 'Stand-out Performers',
      subtitle: 'Pick up to $_standoutsCap',
      athletes: items,
      initiallySelected: _standoutIds,
      maxSelectable: _standoutsCap,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _standoutIds = picked.toSet();
    });
  }

  /// Human-readable summary of the current selection for the trigger's
  /// value slot. Renders as first-initial-last-name comma list up to 2
  /// names + "+N more" tail (matches the To-Do row style on Home).
  String? _standoutsTriggerValue() {
    if (_standoutIds.isEmpty) return null;
    final roster = ref.read(teamRosterProvider(widget.teamId)).value?.roster;
    if (roster == null) return '${_standoutIds.length} selected';
    final selected = <String>[];
    for (final r in roster) {
      if (_standoutIds.contains(r.athlete.id)) {
        selected.add(_formatShortName(r.athlete.firstName, r.athlete.lastName));
      }
    }
    if (selected.isEmpty) return '${_standoutIds.length} selected';
    if (selected.length <= 2) return selected.join(', ');
    return '${selected.take(2).join(', ')} +${selected.length - 2} more';
  }

  static String _formatShortName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }

  Future<void> _publish() async {
    if (_saving || !_anyDirty) return;

    // Guard: scores can't be blank if the coach is publishing. Server
    // would 400 but the client-side check gives a clearer message.
    if (_currentTeamScore == null || _currentOpponentScore == null) {
      setState(() {
        _error = 'Enter both scores before publishing.';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await ref.read(gamesRepositoryProvider).updateGame(
          gameId: widget.game.id,
          teamScore: _teamScoreDirty ? _currentTeamScore : GamesRepository.absent,
          opponentScore: _opponentScoreDirty ? _currentOpponentScore : GamesRepository.absent,
          note: _noteDirty ? _currentNote.trim() : GamesRepository.absent,
          standoutAthleteIds: _standoutsDirty
              ? _standoutIds.toList()
              : GamesRepository.absent,
        );

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        ref.read(gamesProvider(widget.teamId).notifier).replaceGame(data.game);
        if (mounted) context.pop();
      case Failure(:final message):
        setState(() {
          _saving = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctaLabel = _hasExistingReport ? 'Update Report' : 'Publish Report';

    // Body Column pattern (matches auth pages): scrollable content in
    // Expanded, AppScreenFooter as sibling below. Avoids the
    // `Scaffold.bottomNavigationBar` MediaQuery filter that would
    // block the footer's keyboard-hide detection.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: KeyboardDismissible(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppPageInsets.padding,
                  children: [
                    _ScoreRow(
                      teamName: widget.teamName,
                      opponentName: widget.game.opponentName,
                      teamScoreCtrl: _teamScoreCtrl,
                      opponentScoreCtrl: _opponentScoreCtrl,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Stand-out Performers',
                      style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppSelectTrigger(
                      placeholder: 'Select stand out players',
                      value: _standoutsTriggerValue(),
                      onTap: _saving ? null : _openStandoutsSheet,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Game Notes',
                      style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextArea(
                      placeholder: 'Enter any notes for your team',
                      controller: _noteCtrl,
                      enabled: !_saving,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _error!,
                        style: AppTypography.bodyMedium.copyWith(color: colors.error),
                      ),
                    ],
                  ],
                ),
              ),
              AppScreenFooter.single(
                primary: AppButton(
                  label: ctaLabel,
                  onPressed: _anyDirty && !_saving ? _publish : null,
                  loading: _saving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Upcoming preview (scheduled, no scores yet) ───────────────────

class _UpcomingPreview extends StatelessWidget {
  const _UpcomingPreview({required this.game, required this.teamName});

  final Game game;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: AppPageInsets.padding,
      children: [
        AppCard(
          variant: AppCardVariant.unread,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.schedule, color: colors.link, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'This game is upcoming. Reporting opens once it\'s played.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Small helpers ─────────────────────────────────────────────────

/// Compact score input row: "Rampage [0] - [0] Lakers". Two numeric
/// text inputs with team names on the outside.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.teamName,
    required this.opponentName,
    required this.teamScoreCtrl,
    required this.opponentScoreCtrl,
    required this.enabled,
  });

  final String teamName;
  final String opponentName;
  final TextEditingController teamScoreCtrl;
  final TextEditingController opponentScoreCtrl;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TeamLabel(name: teamName, textAlign: TextAlign.end),
          ),
          const SizedBox(width: AppSpacing.md),
          _ScoreBox(controller: teamScoreCtrl, enabled: enabled),
          const SizedBox(width: AppSpacing.xs),
          _Separator(),
          const SizedBox(width: AppSpacing.xs),
          _ScoreBox(controller: opponentScoreCtrl, enabled: enabled),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _TeamLabel(name: opponentName, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  const _TeamLabel({required this.name, required this.textAlign});
  final String name;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: AppTypography.boldLarge.copyWith(color: context.colors.primaryText),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.controller, required this.enabled});
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        textAlign: TextAlign.center,
        style: AppTypography.headlineSmall.copyWith(color: colors.primaryText),
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.secondaryBackground,
          contentPadding: EdgeInsets.zero,
          // Placeholder "0" so an unscored game reads as "0 - 0"
          // visually before the coach types. Not an actual value —
          // the coach still has to type to enable the CTA.
          hintText: '0',
          hintStyle: AppTypography.headlineSmall.copyWith(color: colors.secondaryText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: colors.alternate, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: colors.alternate, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: colors.link, width: 2),
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '-',
      style: AppTypography.headlineSmall.copyWith(
        color: context.colors.secondaryText,
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: AppPageInsets.padding,
      child: Center(
        child: Text(
          'Game not found.',
          style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }
}

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Feb 22"
String _formatShortDate(DateTime dt) => '${_monthAbbr[dt.month - 1]} ${dt.day}';
