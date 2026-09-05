import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_coaches.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_radio_card.dart';
import '../../../../shared/widgets/app_screen_footer.dart';
import '../../../../shared/widgets/app_sheet_layout.dart';
import '../../../../shared/widgets/app_sheet_shell.dart';
import '../../../auth/data/api_result.dart';
import '../../controllers/feedback_requests_providers.dart';

/// Two-state sheet:
///   1. Coach picker — list of AppRadioCards, "Send Request" primary
///      button in the footer, disabled until a coach is selected.
///   2. Success — AppEmptyState (green check + confirmation copy),
///      "Done" primary button that pops the sheet.
///
/// State-swap inside a single sheet (rather than opening a second
/// modal) — cleaner UX; only one drag handle / one dismiss target
/// on screen.
class RequestFeedbackSheet extends ConsumerStatefulWidget {
  const RequestFeedbackSheet({super.key, required this.athleteId});

  final String athleteId;

  @override
  ConsumerState<RequestFeedbackSheet> createState() => _RequestFeedbackSheetState();
}

class _RequestFeedbackSheetState extends ConsumerState<RequestFeedbackSheet> {
  Coach? _selected;
  bool _sending = false;
  String? _error;

  /// After a successful submit, the coach the request went to — used
  /// in the confirmation copy. Null while the form is active.
  Coach? _sentTo;

  Future<void> _send() async {
    final coach = _selected;
    if (coach == null || _sending) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _sending = true;
      _error = null;
    });

    final result = await ref.read(feedbackRequestsRepositoryProvider).createRequest(
          coachId: coach.id,
          teamId: coach.team.id,
        );

    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          _sending = false;
          _sentTo = coach;
        });
      case Failure(:final message):
        setState(() {
          _sending = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSuccess = _sentTo != null;

    return AppSheetLayout(
      title: onSuccess ? 'Request Sent' : 'Request Feedback',
      subtitle: onSuccess ? null : 'Select a coach to receive feedback from',
      footer: AppScreenFooter.single(
        primary: AppButton(
          label: onSuccess ? 'Done' : 'Send Request',
          onPressed: onSuccess
              ? () => Navigator.of(context).pop()
              : (_selected != null && !_sending ? _send : null),
          loading: !onSuccess && _sending,
        ),
      ),
      child: onSuccess ? _SuccessBody(sentTo: _sentTo!) : _formBody(),
    );
  }

  Widget _formBody() {
    final colors = context.colors;
    final async = ref.watch(coachesProvider(widget.athleteId));

    return async.when(
      data: (data) {
        final coaches = data?.coaches ?? const <Coach>[];
        if (coaches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: AppEmptyState(
              icon: AppIcons.userFallback,
              iconColor: colors.secondaryText,
              title: 'No coaches available',
              subtitle: 'You have no coaches on your active team yet.',
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < coaches.length; i++) ...[
              AppRadioCard(
                title: _coachTitle(coaches[i]),
                subtitle: _coachSubtitle(coaches[i]),
                selected: _selected?.id == coaches[i].id &&
                    _selected?.team.id == coaches[i].team.id,
                onTap: _sending ? () {} : () => setState(() => _selected = coaches[i]),
              ),
              if (i < coaches.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(color: colors.error),
              ),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: AppLoadingIndicator()),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Text(
          'Could not load coaches.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
        ),
      ),
    );
  }

  /// "Coach Jesse" — first-name prefixed. Matches the design mock.
  static String _coachTitle(Coach c) => 'Coach ${c.firstName}';

  /// "Head Coach · Rampage U13" — role + team.
  static String _coachSubtitle(Coach c) {
    final role = _roleLabel(c.coachType);
    final team = c.team.name;
    return team.isEmpty ? role : '$role · $team';
  }

  static String _roleLabel(CoachType type) => switch (type) {
        CoachType.HEAD_COACH => 'Head Coach',
        CoachType.ASSISTANT_COACH => 'Assistant Coach',
        CoachType.SKILLS_COACH => 'Skills Coach',
        CoachType.OFFSEASON_COACH => 'Spring/Summer Coach',
      };
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.sentTo});
  final Coach sentTo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: AppEmptyState(
        icon: AppIcons.checkCircle,
        iconColor: colors.success,
        title: 'Request Sent Successfully',
        subtitle:
            'Coach ${sentTo.firstName} has been notified and will rate your skills as soon as possible. Feedback will appear on your passport automatically.',
      ),
    );
  }
}

/// Convenience opener — same pattern as the other sheet openers.
Future<void> showRequestFeedbackSheet(
  BuildContext context, {
  required String athleteId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => RequestFeedbackSheet(athleteId: athleteId),
  );
}
