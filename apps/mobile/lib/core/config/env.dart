// ignore_for_file: do_not_use_environment

/// Compile-time configuration injected via --dart-define.
///
/// Dev usage:
///   flutter run --dart-define=API_BASE_URL=http://localhost:3001
///
/// Android emulator: localhost does NOT resolve — use 10.0.2.2 instead:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001
///
/// iOS simulator: localhost resolves normally.
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
