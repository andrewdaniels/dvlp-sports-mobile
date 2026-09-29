import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/theme.dart';
import '../../features/assessments/controllers/assessments_providers.dart';
import '../../features/assessments/ui/sheets/skill_score_selector_sheet.dart';
import '../../features/assessments/ui/widgets/score_gauge.dart';
import '../../features/auth/controllers/profile_providers.dart';
import '../../features/help/ui/how_it_works_sheet.dart';
import '../../features/auth/data/api_result.dart';
import '../../generated/api/get_assessment_detail.dart' as detail_api;
import '../../generated/api/get_assessment_schema.dart' as schema_api;
import '../../generated/api/get_profile.dart' as profile_api;
import '../../shared/widgets/app_audio_note.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_detail_app_bar.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/app_screen_footer.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_area.dart';
import '../../shared/widgets/keyboard_dismissible.dart';

/// Formal assessment view — three modes driven by constructor + auth:
///
///   - `readonly` (viewer is not the coach author) → same layout the
///     athlete has always seen: coach header + scoring gauges + notes.
///   - `editExisting` (viewer coach == assessment author) → same layout
///     but gauges become tappable and the notes field becomes editable;
///     Save CTA footer appears.
///   - `create` (assessmentId == null) → athlete header, seeded from
///     composerSchemaProvider(teamId); Submit CTA footer.
///
/// The single `_FormalComposer` stateful widget owns editing state for
/// both editExisting + create so the composer surface is defined once.
/// The read-only body is a separate stateless widget.
class FormalFeedbackPage extends ConsumerWidget {
  const FormalFeedbackPage({
    super.key,
    this.assessmentId,
    this.newForAthleteId,
    this.newForTeamId,
  }) : assert(
          assessmentId != null ||
              (newForAthleteId != null && newForTeamId != null),
          'Either assessmentId OR (newForAthleteId + newForTeamId) is required.',
        );

  final String? assessmentId;
  final String? newForAthleteId;
  final String? newForTeamId;

  bool get _isCreate => assessmentId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppDetailAppBar(
        title: _isCreate ? 'Formal Assessment' : 'Feedback',
        actions: [
          AppIconButton(
            icon: AppIcons.messageQuestionSquare,
            size: AppIconButtonSize.large,
            onPressed: () {
              HapticFeedback.lightImpact();
              showHowItWorksSheet(context);
            },
          ),
        ],
      ),
      body: _isCreate
          ? _CreateBody(
              athleteId: newForAthleteId!,
              teamId: newForTeamId!,
            )
          : _ExistingBody(assessmentId: assessmentId!),
    );
  }
}

// ─── Existing (view/edit) ────────────────────────────────────────────

class _ExistingBody extends ConsumerWidget {
  const _ExistingBody({required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(assessmentDetailProvider(assessmentId));
    final callerId = SupabaseService.client.auth.currentSession?.user.id;

    return AppRefreshIndicator(
      onRefresh: () =>
          ref.read(assessmentDetailProvider(assessmentId).notifier).refresh(),
      child: async.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Something went wrong.',
            style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return Center(
              child: Text(
                'Feedback not found.',
                style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
              ),
            );
          }
          final canEdit = callerId != null && detail.coach?.id == callerId;
          if (!canEdit) return _ReadonlyBody(detail: detail);
          return _FormalComposer(
            existingAssessmentId: assessmentId,
            // athleteId + teamId aren't returned by get-assessment-detail
            // yet, so edit mode passes null. Cache invalidation on save
            // covers the coach summary + the detail itself; the athlete's
            // list stays stale until they refresh. Follow-up: surface
            // athlete_id + team_id on the detail response.
            athleteId: null,
            teamId: null,
            skills: [
              for (final s in detail.scores)
                _ComposerSkill(
                  id: s.skillId,
                  name: s.skillName,
                  description: s.skillDescription,
                  initialScore: s.score.toDouble(),
                  previousScore: s.previousScore?.toDouble(),
                ),
            ],
            scoreScale: _ScoreScale(
              min: detail.scoreScale.min.toDouble(),
              max: detail.scoreScale.max.toDouble(),
              step: detail.scoreScale.step.toDouble(),
            ),
            initialNote: detail.notes ?? '',
            // Edit mode reuses the coach header until we surface
            // athlete_id on the detail response (V2). Coach knows who
            // they wrote for; the header just anchors the page.
            headerBuilder: (_) => _CoachHeader(detail: detail),
          );
        },
      ),
    );
  }
}

class _ReadonlyBody extends StatelessWidget {
  const _ReadonlyBody({required this.detail});
  final detail_api.Assessment detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: AppPageInsets.padding,
      children: [
        _CoachHeader(detail: detail),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < detail.scores.length; i++) ...[
          ScoreGauge(
            title: detail.scores[i].skillName,
            description: detail.scores[i].skillDescription,
            score: detail.scores[i].score.toDouble(),
            maxScore: detail.scoreScale.max.toDouble(),
            previousScore: detail.scores[i].previousScore?.toDouble(),
          ),
          if (i < detail.scores.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
        const SizedBox(height: AppSpacing.xxl),
        // Only render the Coach's Note section if there's something to
        // show — an audio note, a text note, or both. Skips the visual
        // altogether for assessments where the coach didn't attach either.
        if ((detail.voiceNoteUrl ?? '').isNotEmpty ||
            (detail.notes ?? '').isNotEmpty) ...[
          Text(
            "Coach's Note",
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          if ((detail.voiceNoteUrl ?? '').isNotEmpty)
            AppAudioNote(audioUrl: detail.voiceNoteUrl),
          if ((detail.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              detail.notes!,
              style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
            ),
          ],
        ],
      ],
    );
  }
}

// ─── Create ──────────────────────────────────────────────────────────

class _CreateBody extends ConsumerWidget {
  const _CreateBody({required this.athleteId, required this.teamId});

  final String athleteId;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // Fetch the athlete first so we know their position, then key the
    // composer schema by (team, position) — the returned skills are
    // scoped to that position server-side (a goalie doesn't get
    // scored on shooting, etc.). If athlete isn't loaded yet the key
    // has a null positionId and we defer the schema fetch until it is.
    final athleteAsync = ref.watch(athleteProfileProvider(athleteId));
    final positionId = athleteAsync.value?.athleteDetails?.position?.id;
    final schemaAsync = athleteAsync.isLoading
        ? const AsyncLoading<schema_api.GetAssessmentSchemaData?>()
        : ref.watch(composerSchemaProvider(
            (teamId: teamId, positionId: positionId),
          ));

    if (schemaAsync.isLoading || athleteAsync.isLoading) {
      return const Center(child: AppLoadingIndicator());
    }
    final schema = schemaAsync.value;
    final athlete = athleteAsync.value;
    if (schema == null || athlete == null) {
      return Padding(
        padding: AppPageInsets.padding,
        child: Center(
          child: Text(
            'Could not load the assessment form.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
          ),
        ),
      );
    }

    return _FormalComposer(
      existingAssessmentId: null,
      athleteId: athleteId,
      teamId: teamId,
      skills: [
        for (final s in schema.skills)
          _ComposerSkill(
            id: s.id,
            name: s.name,
            description: s.description,
            initialScore: null,
            previousScore: null,
          ),
      ],
      scoreScale: _ScoreScale(
        min: schema.scoreScale.min.toDouble(),
        max: schema.scoreScale.max.toDouble(),
        step: schema.scoreScale.step.toDouble(),
      ),
      initialNote: '',
      headerBuilder: (_) => _AthleteHeader(profile: athlete),
    );
  }
}

// ─── Composer (shared by create + editExisting) ──────────────────────

class _ComposerSkill {
  const _ComposerSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.initialScore,
    required this.previousScore,
  });
  final String id;
  final String name;
  final String? description;
  final double? initialScore;
  final double? previousScore;
}

class _ScoreScale {
  const _ScoreScale({required this.min, required this.max, required this.step});
  final double min;
  final double max;
  final double step;
}

class _FormalComposer extends ConsumerStatefulWidget {
  const _FormalComposer({
    required this.existingAssessmentId,
    required this.athleteId,
    required this.teamId,
    required this.skills,
    required this.scoreScale,
    required this.initialNote,
    required this.headerBuilder,
  }) : assert(
          existingAssessmentId != null || (athleteId != null && teamId != null),
          'Create mode requires athleteId + teamId.',
        );

  final String? existingAssessmentId;
  // Present in create mode; null in edit mode (get-assessment-detail
  // doesn't return them today). Update flow doesn't need them —
  // athlete-list invalidation is skipped when athleteId is null.
  final String? athleteId;
  final String? teamId;
  final List<_ComposerSkill> skills;
  final _ScoreScale scoreScale;
  final String initialNote;
  final WidgetBuilder headerBuilder;

  bool get isCreate => existingAssessmentId == null;

  @override
  ConsumerState<_FormalComposer> createState() => _FormalComposerState();
}

class _FormalComposerState extends ConsumerState<_FormalComposer> {
  late final Map<String, double?> _scores;
  late final TextEditingController _noteCtrl;
  bool _saving = false;
  String? _error;
  String? _voiceNoteFilePath;

  @override
  void initState() {
    super.initState();
    _scores = {
      for (final s in widget.skills) s.id: s.initialScore,
    };
    _noteCtrl = TextEditingController(text: widget.initialNote);
    _noteCtrl.addListener(_rebuildOnChange);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _rebuildOnChange() {
    if (mounted) setState(() {});
  }

  bool get _noteDirty => _noteCtrl.text.trim() != widget.initialNote.trim();
  bool get _scoresDirty {
    for (final s in widget.skills) {
      if (_scores[s.id] != s.initialScore) return true;
    }
    return false;
  }

  bool get _canSubmit {
    // Formal requires EVERY skill in the composer to have a score —
    // the whole point of a formal is a full evaluation. Client-side
    // gate; server enforces "at least one" as a safety net.
    final allScored = widget.skills.every((s) => _scores[s.id] != null);
    if (widget.isCreate) return allScored && !_saving;
    // Edit: still must be fully scored AND have at least one dirty
    // field (a score changed, the note changed, or a new voice note
    // was recorded).
    final hasChange = _scoresDirty || _noteDirty || _voiceNoteFilePath != null;
    return allScored && hasChange && !_saving;
  }

  Future<void> _openScoreSheet(_ComposerSkill skill) async {
    final picked = await showSkillScoreSelectorSheet(
      context: context,
      skillName: skill.name,
      currentScore: _scores[skill.id],
      min: widget.scoreScale.min,
      max: widget.scoreScale.max,
      step: widget.scoreScale.step,
    );
    if (picked == null || !mounted) return;
    setState(() => _scores[skill.id] = picked);
  }

  Future<void> _save() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _saving = true;
      _error = null;
    });

    final scoreList = <({String skillId, num score})>[
      for (final entry in _scores.entries)
        if (entry.value != null) (skillId: entry.key, score: entry.value!),
    ];

    // Read the local recording (if any) + base64-encode. Small enough
    // (~500KB for 60s) to do inline without an isolate.
    String? voiceNoteBase64;
    if (_voiceNoteFilePath != null) {
      try {
        final bytes = await File(_voiceNoteFilePath!).readAsBytes();
        voiceNoteBase64 = base64Encode(bytes);
      } catch (_) {
        // Best-effort: submit without the audio if the file went away.
        voiceNoteBase64 = null;
      }
    }

    final actions = ref.read(assessmentActionsProvider);
    final result = widget.isCreate
        ? await actions.create(
            assessmentType: 'formal',
            athleteId: widget.athleteId!,
            teamId: widget.teamId!,
            status: 'submitted',
            notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            scores: scoreList,
            voiceNoteBase64: voiceNoteBase64,
          )
        : await actions.update(
            assessmentId: widget.existingAssessmentId!,
            athleteId: widget.athleteId,
            status: 'submitted',
            notes: _noteDirty ? _noteCtrl.text.trim() : null,
            scores: _scoresDirty ? scoreList : null,
            voiceNoteBase64: voiceNoteBase64,
          );

    if (!mounted) return;

    switch (result) {
      case Success():
        AppSnackBar.show(
          context,
          message: widget.isCreate ? 'Feedback submitted.' : 'Feedback updated.',
          variant: AppSnackBarVariant.success,
        );
        context.pop();
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
    final ctaLabel = widget.isCreate ? 'Submit' : 'Save';

    return SafeArea(
      bottom: false,
      child: KeyboardDismissible(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppPageInsets.padding,
                children: [
                  widget.headerBuilder(context),
                  const SizedBox(height: AppSpacing.xl),
                  for (var i = 0; i < widget.skills.length; i++) ...[
                    ScoreGauge(
                      title: widget.skills[i].name,
                      description: widget.skills[i].description,
                      score: _scores[widget.skills[i].id],
                      maxScore: widget.scoreScale.max,
                      previousScore: widget.skills[i].previousScore,
                      onTap: () => _openScoreSheet(widget.skills[i]),
                    ),
                    if (i < widget.skills.length - 1)
                      const SizedBox(height: AppSpacing.xl),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    "Coach's Note",
                    style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextArea(
                    controller: _noteCtrl,
                    placeholder: 'Add notes for the athlete (optional)',
                    minLines: 3,
                    maxLines: 8,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppAudioNote(
                    onRecorded: (path) =>
                        setState(() => _voiceNoteFilePath = path),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: AppTypography.labelSmall.copyWith(color: colors.error),
                    ),
                  ],
                ],
              ),
            ),
            AppScreenFooter.single(
              primary: AppButton(
                label: ctaLabel,
                variant: AppButtonVariant.primary,
                loading: _saving,
                onPressed: _canSubmit ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Headers ─────────────────────────────────────────────────────────

class _CoachHeader extends StatelessWidget {
  const _CoachHeader({required this.detail});
  final detail_api.Assessment detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final coach = detail.coach;
    final teamSuffix = detail.accessScope == detail_api.AccessScope.EXTERNAL
        ? 'External'
        : [
            detail.team.name.trim(),
            (detail.team.ageGroup ?? '').trim(),
            (detail.team.level ?? '').trim(),
          ].where((s) => s.isNotEmpty).join(' ');
    final teamLine = [
      _roleLabel(detail.weightedRole),
      teamSuffix,
    ].where((s) => s.isNotEmpty).join(' · ');

    // Coach null = hard-deleted account. Render placeholder header —
    // the assessment content below still reflects their work.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: coach?.avatarUrl,
          firstName: coach?.firstName ?? '',
          lastName: coach?.lastName ?? '',
          size: AppAvatarSize.medium,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                coach == null ? 'Deleted coach' : 'Coach ${coach.firstName}',
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                teamLine,
                style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _roleLabel(detail_api.WeightedRole role) => switch (role) {
        detail_api.WeightedRole.HEAD_COACH => 'Head Coach',
        detail_api.WeightedRole.ASSISTANT_COACH => 'Assistant Coach',
        detail_api.WeightedRole.SKILLS_COACH => 'Skills Coach',
        detail_api.WeightedRole.OFFSEASON_COACH => 'Offseason Coach',
      };
}

class _AthleteHeader extends StatelessWidget {
  const _AthleteHeader({required this.profile});
  final profile_api.GetProfileData profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = _displayName(profile.firstName, profile.lastName);
    final teamLine = _composeTeamLine(profile);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: profile.avatarUrl,
          firstName: profile.firstName,
          lastName: profile.lastName,
          size: AppAvatarSize.medium,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
              if (teamLine.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  teamLine,
                  style: AppTypography.boldSmall.copyWith(color: colors.secondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _displayName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }

  static String _composeTeamLine(profile_api.GetProfileData profile) {
    final m = profile.teamMemberships.isNotEmpty ? profile.teamMemberships.first : null;
    final team = m?.team;
    final positionName = profile.athleteDetails?.position?.name;
    final teamText = [
      team?.name.trim() ?? '',
      (team?.ageGroup ?? '').trim(),
      (team?.levelClassification ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    if (teamText.isEmpty && (positionName ?? '').isEmpty) return '';
    if (teamText.isEmpty) return positionName!;
    if ((positionName ?? '').isEmpty) return teamText;
    return '$teamText | $positionName';
  }
}

