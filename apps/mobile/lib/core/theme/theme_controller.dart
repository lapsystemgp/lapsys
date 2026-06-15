import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeMode = 'theme_mode';

/// Holds the user-selected [ThemeMode].
///
/// Defaults to [ThemeMode.system] (follow the device light/dark setting).
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kThemeMode);
    if (name != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode.name);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(),
);
