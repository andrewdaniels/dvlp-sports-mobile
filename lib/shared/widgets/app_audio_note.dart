import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';
import 'app_icon_button.dart';

/// Audio note recorder + playback player. Leading control (mic/stop/play)
/// on the left, elapsed time next to it, waveform filling the remainder.
///
/// Modes:
/// - **Recording** (default when `audioUrl` is null): starts in idle with a
///   mic button (`secondaryText` tint). Tap → recording state (red waveform,
///   red-tinted stop button, timer). Tap stop → complete state (waveform +
///   play button).
/// - **Playback-only** (when `audioUrl` provided): shows waveform + play/pause.
///
/// **Audio is not wired yet.** This widget is the visual + state-machine
/// shell so we can iterate on UX. When we build the assessment/feedback
/// feature, we plug in:
///   - `record` (or `flutter_sound`) — captures audio + amplitude stream
///   - `just_audio` — playback
///   - `permission_handler` — mic permission (asked inside this widget)
/// Real waveform bars use amplitude samples; the demo pattern below is
/// static.
class AppAudioNote extends StatefulWidget {
  const AppAudioNote({
    super.key,
    this.audioUrl,
    this.onRecorded,
    this.maxDurationSeconds = 60,
  });

  /// If provided, widget starts in playback-only mode showing this audio.
  final String? audioUrl;

  /// Callback with audio file path when a recording is completed.
  /// (TODO: wire when audio integration lands.)
  final ValueChanged<String>? onRecorded;

  final int maxDurationSeconds;

  @override
  State<AppAudioNote> createState() => _AppAudioNoteState();
}

enum _AudioMode { idleRecording, recording, complete }

class _AppAudioNoteState extends State<AppAudioNote> {
  late _AudioMode _mode;
  Timer? _tick;
  int _elapsedSeconds = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.audioUrl != null ? _AudioMode.complete : _AudioMode.idleRecording;
    if (widget.audioUrl != null) {
      _elapsedSeconds = 63; // demo duration
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _startRecording() {
    // TODO(audio): request mic permission via permission_handler; if granted,
    // start recording via `record` package.
    setState(() {
      _mode = _AudioMode.recording;
      _elapsedSeconds = 0;
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= widget.maxDurationSeconds) _stopRecording();
    });
  }

  void _stopRecording() {
    _tick?.cancel();
    _tick = null;
    // TODO(audio): stop the recorder, invoke widget.onRecorded with the file path.
    setState(() => _mode = _AudioMode.complete);
  }

  void _togglePlayback() {
    // TODO(audio): start/pause playback via just_audio.
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.alternate, width: 1),
      ),
      child: Row(
        children: [
          _leadingControl(context),
          const SizedBox(width: AppSpacing.sm),
          Text(_formatDuration(_elapsedSeconds), style: AppTypography.bodySmall.copyWith(color: colors.primaryText)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Waveform(mode: _mode, isPlaying: _isPlaying)),
        ],
      ),
    );
  }

  Widget _leadingControl(BuildContext context) {
    final colors = context.colors;
    switch (_mode) {
      case _AudioMode.idleRecording:
        return AppIconButton(
          icon: AppIcons.microphone,
          onPressed: _startRecording,
          variant: AppIconButtonVariant.tinted,
          tintColor: colors.secondaryText,
          size: AppIconButtonSize.small,
        );
      case _AudioMode.recording:
        return AppIconButton(
          icon: AppIcons.stopFilled,
          onPressed: _stopRecording,
          variant: AppIconButtonVariant.tinted,
          tintColor: colors.error,
          size: AppIconButtonSize.small,
        );
      case _AudioMode.complete:
        return AppIconButton(
          icon: _isPlaying ? AppIcons.pauseFilled : AppIcons.playFilled,
          onPressed: _togglePlayback,
          variant: AppIconButtonVariant.tinted,
          tintColor: colors.secondaryText,
          size: AppIconButtonSize.small,
        );
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Static waveform visualization. Recording state paints in `error`;
/// playback paints in `primaryText`.
/// (TODO: replace with real amplitude data from the recorder / decoded audio.)
class _Waveform extends StatelessWidget {
  const _Waveform({required this.mode, required this.isPlaying});

  final _AudioMode mode;
  final bool isPlaying;

  // Pre-generated deterministic bar heights (0.15..1.0) so the waveform
  // looks realistic without random per-build churn.
  static final List<double> _amps = List.generate(52, (i) {
    final v = 0.3 + 0.7 * (math.sin(i * 0.5) * math.cos(i * 0.31)).abs();
    return v.clamp(0.15, 1.0);
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color barColor;
    if (mode == _AudioMode.recording) {
      barColor = colors.error;
    } else if (mode == _AudioMode.complete && isPlaying) {
      barColor = colors.primaryText;
    } else if (mode == _AudioMode.complete) {
      barColor = colors.primaryText70;
    } else {
      barColor = colors.alternate;
    }

    return SizedBox(
      height: 28,
      child: LayoutBuilder(builder: (context, constraints) {
        const barWidth = 2.0;
        const barGap = 2.0;
        final maxBars = (constraints.maxWidth / (barWidth + barGap)).floor();
        final bars = _amps.take(maxBars).toList();

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              Container(
                width: barWidth,
                height: 28 * bars[i],
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
              if (i < bars.length - 1) const SizedBox(width: barGap),
            ],
          ],
        );
      }),
    );
  }
}
