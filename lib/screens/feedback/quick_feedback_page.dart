import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/theme.dart';
import '../../features/assessments/controllers/assessments_providers.dart';
import '../../features/assessments/ui/widgets/skill_score_row.dart';
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
import '../../shared/widgets/app_text_area.dart';
import '../../shared/widgets/keyboard_dismissible.dart';

/// Quick feedback view — three modes driven by constructor + auth:
///
///   - `readonly` (viewer is not the coach author) → athlete's current
///     view: coach header + star rows + notes.
///   - `editExisting` (viewer coach == assessment author) → star rows
///     become tappable; Save CTA footer appears.
///   - `create` (assessmentId == null) → athlete header, seeded from
///     composerSchemaProvider(teamId); Submit CTA footer. Optional
///     `requestId` from a pending athlete-authored request marks that
///     request completed atomically on the server side.
class QuickFeedbackPage extends ConsumerWidget {
  const QuickFeedbackPage({
    super.key,
    this.assessmentId,
    this.newForAthleteId,
    this.newForTeamId,
    this.requestId,
  }) : assert(
          assessmentId != null ||
              (newForAthleteId != null && newForTeamId != null),
          'Either assessmentId OR (newForAthleteId + newForTeamId) is required.',
        );

  final String? assessmentId;
  final String? newForAthleteId;
  final String? newForTeamId;

  /// Only meaningful in create mode; links the new quick assessment
  /// to a pending assessment_request (server flips it to completed
  /// in the same transaction).
  final String? requestId;

  bool get _isCreate => assessmentId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppDetailAppBar(
        title: _isCreate ? 'Quick Feedback' : 'Feedback',
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
              requestId: requestId,
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
          final canEdit = callerId != null && detail.coach.id == callerId;
          if (!canEdit) return _ReadonlyBody(detail: detail);
          return _QuickComposer(
            existingAssessmentId: assessmentId,
            athleteId: null,
            teamId: null,
            requestId: null,
            skills: [
              for (final s in detail.scores)
                _ComposerSkill(
                  id: s.skillId,
                  name: s.skillName,
                  description: s.skillDescription,
                  initialScore: s.score.round(),
                ),
            ],
            initialNote: detail.notes ?? '',
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
          SkillScoreRow(
            skillName: detail.scores[i].skillName,
            skillDescription: detail.scores[i].skillDescription,
            score: detail.scores[i].score.round(),
          ),
          if (i < detail.scores.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Text(
          "Coach's Note",
          style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
        ),
        const SizedBox(height: AppSpacing.md),
        // Voice note is visual-only for now. When real playback lands
        // we swap the null for the actual url from the row.
        const AppAudioNote(audioUrl: 'https://placeholder.invalid/audio.m4a'),
        if ((detail.notes ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            detail.notes!,
            style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
          ),
        ],
      ],
    );
  }
}

// ─── Create ──────────────────────────────────────────────────────────

class _CreateBody extends ConsumerWidget {
  const _CreateBody({
    required this.athleteId,
    required this.teamId,
    required this.requestId,
  });

  final String athleteId;
  final String teamId;
  final String? requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // Fetch the athlete first so we know their position, then key the
    // composer schema by (team, position). Server filters skills to
    // that position via `position_skills`.
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
            'Could not load the feedback form.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
          ),
        ),
      );
    }

    return _QuickComposer(
      existingAssessmentId: null,
      athleteId: athleteId,
      teamId: teamId,
      requestId: requestId,
      skills: [
        for (final s in schema.skills)
          _ComposerSkill(
            id: s.id,
            name: s.name,
            description: s.description,
            initialScore: 0,
          ),
      ],
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
  });
  final String id;
  final String name;
  final String? description;
  final int initialScore; // 0 = unset for the star scale
}

class _QuickComposer extends ConsumerStatefulWidget {
  const _QuickComposer({
    required this.existingAssessmentId,
    required this.athleteId,
    required this.teamId,
    required this.requestId,
    required this.skills,
    required this.initialNote,
    required this.headerBuilder,
  }) : assert(
          existingAssessmentId != null || (athleteId != null && teamId != null),
          'Create mode requires athleteId + teamId.',
        );

  final String? existingAssessmentId;
  final String? athleteId;
  final String? teamId;
  final String? requestId;
  final List<_ComposerSkill> skills;
  final String initialNote;
  final WidgetBuilder headerBuilder;

  bool get isCreate => existingAssessmentId == null;

  @override
  ConsumerState<_QuickComposer> createState() => _QuickComposerState();
}

class _QuickComposerState extends ConsumerState<_QuickComposer> {
  late final Map<String, int> _scores;
  late final TextEditingController _noteCtrl;
  bool _saving = false;
  String? _error;

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
      if ((_scores[s.id] ?? 0) != s.initialScore) return true;
    }
    return false;
  }

  bool get _canSubmit {
    final anyScore = _scores.values.any((v) => v > 0);
    if (widget.isCreate) return anyScore && !_saving;
    return anyScore && (_scoresDirty || _noteDirty) && !_saving;
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
        if (entry.value > 0) (skillId: entry.key, score: entry.value),
    ];

    final actions = ref.read(assessmentActionsProvider);
    final result = widget.isCreate
        ? await actions.create(
            assessmentType: 'quick',
            athleteId: widget.athleteId!,
            teamId: widget.teamId!,
            status: 'submitted',
            notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            scores: scoreList,
            requestId: widget.requestId,
          )
        : await actions.update(
            assessmentId: widget.existingAssessmentId!,
            athleteId: widget.athleteId,
            status: 'submitted',
            notes: _noteDirty ? _noteCtrl.text.trim() : null,
            scores: _scoresDirty ? scoreList : null,
          );

    if (!mounted) return;

    switch (result) {
      case Success():
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
                    SkillScoreRow(
                      skillName: widget.skills[i].name,
                      skillDescription: widget.skills[i].description,
                      score: _scores[widget.skills[i].id] ?? 0,
                      onScoreChanged: (v) {
                        setState(() => _scores[widget.skills[i].id] = v);
                      },
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: coach.avatarUrl,
          firstName: coach.firstName,
          lastName: coach.lastName,
          size: AppAvatarSize.medium,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Coach ${coach.firstName}',
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
