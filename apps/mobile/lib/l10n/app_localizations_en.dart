// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TesTly';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueAsPatient => 'Continue as Patient';

  @override
  String get continueAsLab => 'Continue as Lab';

  @override
  String get rolePatient => 'Patient';

  @override
  String get roleLab => 'Lab';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get biometricPrompt => 'Authenticate to continue';

  @override
  String get biometricReason => 'Use biometrics to unlock TesTly';

  @override
  String get labPendingTitle => 'Account Pending Approval';

  @override
  String get labPendingBody =>
      'Your lab account is under review. You\'ll be notified once approved.';

  @override
  String get adminMobileUnsupported =>
      'Admin panel is available on the web only.';

  @override
  String get openWebApp => 'Open Web App';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Something went wrong';

  @override
  String get noResults => 'No results found';

  @override
  String get patientTabLabs => 'Labs';

  @override
  String get patientTabBookings => 'Bookings';

  @override
  String get patientTabResults => 'Results';

  @override
  String get patientTabTrends => 'Trends';

  @override
  String get patientTabProfile => 'Profile';

  @override
  String get labTabDashboard => 'Dashboard';

  @override
  String get labTabAnalytics => 'Analytics';

  @override
  String get labTabReviews => 'Reviews';

  @override
  String get labTabBookings => 'Bookings';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get labName => 'Lab Name';

  @override
  String get registerPatient => 'Register as Patient';

  @override
  String get registerLab => 'Register as Lab';

  @override
  String get egp => 'EGP';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String get validationPasswordLength =>
      'Password must be at least 8 characters';
}
