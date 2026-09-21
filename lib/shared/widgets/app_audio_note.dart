import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart' as record_pkg;

import '../../core/theme/theme.dart';
import 'app_icon.dart';
import 'app_icon_button.dart';
import 'app_snack_bar.dart';

/// Audio note recorder + playback player. Leading control (mic/stop/play)
/// on the left, elapsed time next to it, waveform filling the remainder.
///
/// Split responsibilities across two packages:
///   - Recording via `record` (AAC m4a to a temp file). audio_waveforms'
///     recorder doesn't reliably capture audio on the iOS simulator —
///     it writes a header-only file with no PCM data — so `record` owns
///     capture on both platforms for consistency.
///   - Playback UX via `audio_waveforms.PlayerController` +
///     AudioFileWaveforms. Extracts amplitudes from the recorded (or
///     downloaded) file for a real waveform, tints the played portion,
///     supports drag-to-seek.
///
/// During recording we render a simple animated bar (real amplitude
/// visualization is a follow-up — `record`'s amplitude stream is
/// available). Playback is where the pretty waveform lives.
///
/// Modes:
///   - `idleRecording` — no [audioUrl] and no local recording yet.
///   - `recording` — capturing to a temp .m4a.
///   - `complete` — a recording exists (local file) OR an [audioUrl]
///     was provided; playback UI + controls active.
class AppAudioNote extends StatefulWidget {
  const AppAudioNote({
    super.key,
    this.audioUrl,
    this.onRecorded,
    this.maxDurationSeconds = 60,
  });

  final String? audioUrl;
  final ValueChanged<String>? onRecorded;
  final int maxDurationSeconds;

  @override
  State<AppAudioNote> createState() => _AppAudioNoteState();
}

enum _AudioMode { idleRecording, recording, complete }

class _AppAudioNoteState extends State<AppAudioNote> {
  final record_pkg.AudioRecorder _recorder = record_pkg.AudioRecorder();
  PlayerController? _playerCtrl;
  Timer? _recordTick;
  StreamSubscription<int>? _playerDurationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  _AudioMode _mode = _AudioMode.idleRecording;
  int _elapsedMs = 0;
  bool _isPlaying = false;
  /// Local file path currently loaded into the player. Kept so that we
  /// can re-preparePlayer after playback naturally completes —
  /// audio_waveforms leaves the controller in a "consumed" state where
  /// startPlayer no-ops until preparePlayer is called again.
  String? _currentAudioPath;

  @override
  void initState() {
    super.initState();
    if (widget.audioUrl != null) {
      _mode = _AudioMode.complete;
      _prepareFromUrl(widget.audioUrl!);
    }
  }

  @override
  void dispose() {
    _recordTick?.cancel();
    _playerDurationSub?.cancel();
    _playerStateSub?.cancel();
    _recorder.dispose();
    _playerCtrl?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Microphone permission is required to record.',
        );
      }
      return;
    }

    final tmpPath =
        '${Directory.systemTemp.path}/voice_note_${DateTime.now().microsecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(
        const record_pkg.RecordConfig(
          encoder: record_pkg.AudioEncoder.aacLc,
          bitRate: 64000,
          numChannels: 1,
        ),
        path: tmpPath,
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Could not start recording.');
      }
      return;
    }

    setState(() {
      _mode = _AudioMode.recording;
      _elapsedMs = 0;
    });
    _recordTick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() => _elapsedMs += 250);
      if (_elapsedMs >= widget.maxDurationSeconds * 1000) _stopRecording();
    });
  }

  Future<void> _stopRecording() async {
    _recordTick?.cancel();
    _recordTick = null;
    final path = await _recorder.stop();
    if (!mounted) return;
    // ignore: avoid_print
    print('[AppAudioNote] recorder stopped path=$path');
    if (path == null) {
      setState(() => _mode = _AudioMode.idleRecording);
      return;
    }
    try {
      final size = await File(path).length();
      // ignore: avoid_print
      print('[AppAudioNote] recorded file size=$size bytes');
    } catch (_) {}
    widget.onRecorded?.call(path);
    await _prepareFromPath(path);
    if (!mounted) return;
    setState(() => _mode = _AudioMode.complete);
  }

  Future<void> _prepareFromPath(String path) async {
    _playerDurationSub?.cancel();
    _playerStateSub?.cancel();
    _playerCtrl?.dispose();

    final controller = PlayerController();
    try {
      await controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        // Cap sample count so the extracted waveform fits the pill's
        // width without clipping. AudioFileWaveforms draws all bars
        // at fixed width (waveThickness + spacing = 6px), so ~50 bars
        // fit a typical 300px inner width — 60 samples gives us
        // headroom without overflow.
        noOfSamples: 60,
      );
      // ignore: avoid_print
      print('[AppAudioNote] preparePlayer done. maxDuration=${controller.maxDuration}');
    } catch (e, st) {
      // ignore: avoid_print
      print('[AppAudioNote] preparePlayer threw: $e\n$st');
      controller.dispose();
      if (mounted) setState(() => _playerCtrl = null);
      return;
    }

    _playerDurationSub = controller.onCurrentDurationChanged.listen((durMs) {
      if (!mounted) return;
      setState(() => _elapsedMs = durMs);
    });
    _playerStateSub = controller.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.isPlaying);
    });

    if (!mounted) {
      controller.dispose();
      return;
    }
    _currentAudioPath = path;
    setState(() => _playerCtrl = controller);
  }

  Future<void> _prepareFromUrl(String url) async {
    try {
      final tmp = File(
        '${Directory.systemTemp.path}/voice_note_dl_${DateTime.now().microsecondsSinceEpoch}.m4a',
      );
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        client.close(force: true);
        return;
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      client.close(force: true);
      await tmp.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      await _prepareFromPath(tmp.path);
    } catch (_) {
      // Silent fail — widget stays in "complete" with a disabled play
      // button. Reopening the sheet re-fetches.
    }
  }

  Future<void> _togglePlayback() async {
    final ctrl = _playerCtrl;
    if (ctrl == null) return;
    if (ctrl.playerState.isPlaying) {
      await ctrl.pausePlayer();
      return;
    }
    // After natural completion audio_waveforms leaves the controller
    // in PlayerState.stopped and startPlayer no-ops. Re-prepare with
    // the same file to reset the internal player, then start.
    final needsReprepare = ctrl.playerState == PlayerState.stopped;
    if (needsReprepare && _currentAudioPath != null) {
      try {
        await ctrl.preparePlayer(
          path: _currentAudioPath!,
          shouldExtractWaveform: true,
        );
      } catch (_) {
        return;
      }
      if (mounted) setState(() => _elapsedMs = 0);
    }
    await ctrl.startPlayer();
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
          Text(
            _formatMs(_elapsedMs),
            style: AppTypography.bodySmall.copyWith(color: colors.primaryText),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _waveform(context)),
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
          onPressed: _playerCtrl == null ? null : _togglePlayback,
          variant: AppIconButtonVariant.tinted,
          tintColor: colors.secondaryText,
          size: AppIconButtonSize.small,
        );
    }
  }

  Widget _waveform(BuildContext context) {
    final colors = context.colors;
    switch (_mode) {
      case _AudioMode.idleRecording:
        return SizedBox(
          height: 28,
          child: Center(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: colors.alternate,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      case _AudioMode.recording:
        // Real-amplitude live waveform during recording is a follow-up
        // (record's amplitude stream drives it). For now, a pulsing
        // red bar signals "capturing" without misrepresenting content.
        return SizedBox(
          height: 28,
          child: Center(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        );
      case _AudioMode.complete:
        final ctrl = _playerCtrl;
        if (ctrl == null) return const SizedBox(height: 28);
        return AudioFileWaveforms(
          size: const Size(double.infinity, 28),
          playerController: ctrl,
          enableSeekGesture: true,
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: PlayerWaveStyle(
            // Played portion in the yellow accent for high contrast
            // against the dim unplayed rail. Matches "listen progress"
            // conventions in chat-app voice notes.
            fixedWaveColor: colors.primaryText30,
            liveWaveColor: colors.secondary,
            spacing: 4,
            waveThickness: 2,
            seekLineColor: colors.secondary,
            showSeekLine: false,
          ),
        );
    }
  }

  String _formatMs(int ms) {
    final totalSeconds = (ms / 1000).round();
    final m = (totalSeconds ~/ 60).toString().padLeft(1, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
