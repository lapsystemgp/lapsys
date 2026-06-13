import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBiometricEnabled = 'biometric_enabled';

class BiometricService {
  BiometricService(this._auth, this._prefs);

  final LocalAuthentication _auth;
  final SharedPreferences _prefs;

  bool get isEnabled => _prefs.getBool(_kBiometricEnabled) ?? true;

  Future<void> setEnabled(bool enabled) =>
      _prefs.setBool(_kBiometricEnabled, enabled);

  Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  /// Returns true if authentication succeeded (or biometrics unavailable/disabled).
  Future<bool> authenticate(String localizedReason) async {
    if (!isEnabled) return true;
    if (!await isAvailable()) return true;
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final _sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final biometricServiceProvider = Provider<BiometricService?>((ref) {
  final prefs = ref.watch(_sharedPreferencesProvider).valueOrNull;
  if (prefs == null) return null;
  return BiometricService(LocalAuthentication(), prefs);
});
