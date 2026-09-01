import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Current app theme mode. Watched by `DvlpSportsApp` to drive
/// `MaterialApp.themeMode`. Toggle from Profile → Developer Tools.
///
/// Not persisted across launches — resets to `ThemeMode.system` on cold
/// start. If we want persistence, wrap in a Notifier + shared_preferences.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
