// ignore_for_file: do_not_use_environment

/// Compile-time configuration injected via --dart-define.
///
/// Defaults to the deployed Railway backend so the app works on real devices
/// and simulators out of the box (over Wi-Fi or cellular).
///
/// To target a local backend instead, override at run time:
///   iOS simulator:    flutter run --dart-define=API_BASE_URL=http://localhost:3001
///   Android emulator: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001
///   Physical device:  flutter run --dart-define=API_BASE_URL=http://<your-mac-lan-ip>:3001
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://testly-backend-production-c28a.up.railway.app',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
