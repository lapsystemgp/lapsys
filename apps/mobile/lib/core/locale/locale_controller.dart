import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleCode = 'locale_code';

/// Holds the user-selected app locale.
///
/// A `null` state means "follow the device language" — in that case
/// [MaterialApp.locale] stays null and Flutter resolves the system locale.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleCode);
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  /// Persists and applies [locale]. Pass `null` to fall back to the device
  /// language.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleCode);
    } else {
      await prefs.setString(_kLocaleCode, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(),
);
