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
  String get patientTabHome => 'Home';

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

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get continueAction => 'Continue';

  @override
  String get bookNow => 'Book Now';

  @override
  String get book => 'Book';

  @override
  String get viewLab => 'View Lab';

  @override
  String get sortBy => 'Sort by';

  @override
  String get enable => 'Enable';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get notNow => 'Not now';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get total => 'Total';

  @override
  String get payment => 'Payment';

  @override
  String get typeLabel => 'Type';

  @override
  String get price => 'Price';

  @override
  String get rating => 'Rating';

  @override
  String get slot => 'Slot';

  @override
  String get document => 'Document';

  @override
  String get homeCollection => 'Home collection';

  @override
  String get homeTestKit => 'Home Test Kit';

  @override
  String get labVisit => 'Lab Visit';

  @override
  String get homeCollectionOnly => 'Home collection only';

  @override
  String get findTestOrLab => 'Find a Test or Lab';

  @override
  String get labFilters => 'Lab filters';

  @override
  String get searchHint => 'Search tests (e.g. CBC) or labs…';

  @override
  String get testsTab => 'Tests';

  @override
  String get labsTab => 'Labs';

  @override
  String get bestRating => 'Best rating';

  @override
  String get lowestPrice => 'Lowest price';

  @override
  String get nearest => 'Nearest';

  @override
  String get noTestsFound => 'No tests found';

  @override
  String get tryDifferentTestName => 'Try a different test name';

  @override
  String get noLabsFound => 'No labs found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String fromPriceEgp(String price) {
    return 'From $price EGP';
  }

  @override
  String labCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count labs',
      one: '1 lab',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String distance) {
    return '$distance km';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get homeGreetingGuest => 'Welcome 👋';

  @override
  String get homeTrustBadge => 'Egypt\'s Trusted Medical Lab Platform';

  @override
  String get homeHeadline => 'Find the best medical labs near you';

  @override
  String get homeSubtitle =>
      'Compare prices, ratings, and book appointments instantly.';

  @override
  String get homeSearchHint => 'Test name or symptoms…';

  @override
  String get browseBy => 'Browse by';

  @override
  String get popular => 'Popular';

  @override
  String get topRated => 'Top Rated';

  @override
  String get bestPrice => 'Best Price';

  @override
  String get featuredLabs => 'Featured Labs';

  @override
  String get featuredLabsSubtitle =>
      'Top-rated labs available for booking right now';

  @override
  String get viewAll => 'View all';

  @override
  String get whyChooseTestly => 'Why Choose TesTly?';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get featureComparePricesTitle => 'Compare Prices';

  @override
  String get featureComparePricesDesc =>
      'See prices from multiple labs instantly';

  @override
  String get featureReviewsTitle => 'Verified Reviews';

  @override
  String get featureReviewsDesc => 'Real reviews from real patients';

  @override
  String get featureHomeCollectionTitle => 'Home Collection';

  @override
  String get featureHomeCollectionDesc => 'Book sample collection at home';

  @override
  String get featureDigitalResultsTitle => 'Digital Results';

  @override
  String get featureDigitalResultsDesc => 'Get your results as a PDF in-app';

  @override
  String get stepSearchTitle => 'Search';

  @override
  String get stepSearchDesc => 'Enter a test name or symptoms';

  @override
  String get stepCompareTitle => 'Compare';

  @override
  String get stepCompareDesc => 'View labs, prices & ratings';

  @override
  String get stepBookTitle => 'Book';

  @override
  String get stepBookDesc => 'Schedule your appointment';

  @override
  String get stepResultsTitle => 'Get Results';

  @override
  String get stepResultsDesc => 'Receive digital PDF results';

  @override
  String labsOfferingTest(String testName) {
    return 'Labs offering $testName';
  }

  @override
  String get noLabsOfferTest => 'No labs offer this test yet';

  @override
  String resultsIn(String turnaround) {
    return 'Results in $turnaround';
  }

  @override
  String parametersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameters',
      one: '1 parameter',
    );
    return '$_temp0';
  }

  @override
  String atLabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'At $count labs',
      one: 'At 1 lab',
    );
    return '$_temp0';
  }

  @override
  String get enableLocationForSort =>
      'Enable location to sort labs by how near they are.';

  @override
  String get noTestsAvailable => 'No tests available';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get chooseBookingType => 'Choose booking type';

  @override
  String get chooseTimeSlot => 'Choose a time slot';

  @override
  String get enterHomeAddress => 'Enter home address';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get confirmBookingStep => 'Confirm booking';

  @override
  String get processingEllipsis => 'Processing…';

  @override
  String get bookingConfirmedBang => 'Booking confirmed!';

  @override
  String get bookingFailed => 'Booking failed';

  @override
  String get howToTakeTest => 'How would you like to take this test?';

  @override
  String get visitLabInPerson => 'Visit the lab in person';

  @override
  String get phlebotomistVisitsHome => 'A phlebotomist visits your home';

  @override
  String get kitShippedSelfCollect => 'Kit shipped to you; self-collect sample';

  @override
  String get noSlotsAvailable7Days => 'No slots available in the next 7 days';

  @override
  String get continueWithoutSlot => 'Continue without a slot';

  @override
  String get enterAddressForService => 'Enter the address for the service:';

  @override
  String get homeAddressLabel => 'Home address';

  @override
  String get streetApartmentCityHint => 'Street, apartment, city…';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get paymentOnlineDemo => 'Online (demo)';

  @override
  String get paymentCashAtLab => 'Cash at lab';

  @override
  String get paymentCashOnCollection => 'Cash on collection';

  @override
  String get paymentCashOnDelivery => 'Cash on delivery';

  @override
  String bookingCreatedFor(String testName, String labName) {
    return 'Your booking for $testName at $labName has been created.';
  }

  @override
  String get viewMyBookings => 'View My Bookings';

  @override
  String get backToLabs => 'Back to Labs';

  @override
  String get confirmBookingButton => 'Confirm Booking';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get noUpcomingBookings => 'No upcoming bookings';

  @override
  String get noPastBookings => 'No past bookings';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get bookingDetail => 'Booking Detail';

  @override
  String cancelFailed(String error) {
    return 'Cancel failed: $error';
  }

  @override
  String get paymentSuccessful => 'Payment successful!';

  @override
  String paymentFailedMsg(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get retryPayment => 'Retry Payment';

  @override
  String get payStatus => 'Pay status';

  @override
  String get payStatusPending => 'Pending';

  @override
  String get payStatusPaid => 'Paid';

  @override
  String get payStatusFailed => 'Failed';

  @override
  String get payStatusRefunded => 'Refunded';

  @override
  String get kitTracking => 'Kit Tracking';

  @override
  String trackingNumber(String number) {
    return 'Tracking #$number';
  }

  @override
  String get awaitingShipment => 'Awaiting shipment';

  @override
  String get kitShipped => 'Kit shipped';

  @override
  String get kitDelivered => 'Kit delivered';

  @override
  String get sampleReceived => 'Sample received';

  @override
  String get statusHistory => 'Status History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get account => 'Account';

  @override
  String get personalInfo => 'Personal info';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get privacy => 'Privacy';

  @override
  String get shareHistoryAcrossLabs => 'Share history across labs';

  @override
  String get enableCrossLabTrends =>
      'Enable cross-lab health trends and comparisons';

  @override
  String get allLabsSeeHistory =>
      'All labs you have tested with can see your full history to power trend charts.';

  @override
  String get onlyTestingLabSeesResult =>
      'Only the lab that performed a test can see that result.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get signOut => 'Sign Out';

  @override
  String get myResults => 'My Results';

  @override
  String get noResultsYet => 'No results yet';

  @override
  String get completedTestsWillAppear => 'Completed tests will appear here';

  @override
  String get resultStatusPending => 'Pending';

  @override
  String get resultStatusUploaded => 'Uploaded';

  @override
  String get resultStatusDelivered => 'Delivered';

  @override
  String get resultStatusStructured => 'Structured';

  @override
  String get result => 'Result';

  @override
  String get resultDetail => 'Result Detail';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get writeReview => 'Write a Review';

  @override
  String rateExperience(String labName) {
    return 'Rate your experience at $labName';
  }

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get reviewSubmitted => 'Review submitted!';

  @override
  String failedToSubmit(String error) {
    return 'Failed to submit: $error';
  }

  @override
  String get summary => 'Summary';

  @override
  String get yourReview => 'Your Review';

  @override
  String couldNotOpenDocument(String error) {
    return 'Could not open document: $error';
  }

  @override
  String get healthTrends => 'Health Trends';

  @override
  String get period3mo => '3 mo';

  @override
  String get period6mo => '6 mo';

  @override
  String get period12mo => '12 mo';

  @override
  String get periodAll => 'All';

  @override
  String get byAnalyte => 'By Analyte';

  @override
  String get byTest => 'By Test';

  @override
  String get noTrendsInPeriod =>
      'No trends in the selected period. Try a wider time range.';

  @override
  String get noStructuredDataYet => 'No structured data yet';

  @override
  String get structuredDataExplanation =>
      'When labs enter your test values as structured data, trends and charts will appear here.';

  @override
  String get recentReadings => 'Recent readings';

  @override
  String get trendRising => 'Rising';

  @override
  String get trendFalling => 'Falling';

  @override
  String get trendStable => 'Stable';

  @override
  String get trendNotEnoughData => 'Not enough data';

  @override
  String get pdfOnlyResults => 'PDF-only results';

  @override
  String get pdfOnlyResultsDesc =>
      'These results have a PDF but no structured data for trending.';

  @override
  String get low => 'Low';

  @override
  String get high => 'High';

  @override
  String get totalBookings => 'Total Bookings';

  @override
  String get pendingResults => 'Pending Results';

  @override
  String get revenue => 'Revenue';

  @override
  String get slotCapacityUsed => 'Slot Capacity Used';

  @override
  String get labStaffCollectSamples =>
      'Lab staff collect samples at patient\'s home';

  @override
  String get shipKitToPatientAddress => 'Ship kit to patient\'s address';

  @override
  String get saveCapabilities => 'Save Capabilities';

  @override
  String get capabilitiesUpdated => 'Capabilities updated';

  @override
  String get capabilities => 'Capabilities';

  @override
  String failedWithError(String error) {
    return 'Failed: $error';
  }

  @override
  String get stayUpToDate => 'Stay up to date';

  @override
  String get notificationPermissionBody =>
      'Get instant alerts when your booking is confirmed, results are ready, or your kit ships — and reminders the evening before tests that need preparation.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock TesTly';

  @override
  String get authenticateButton => 'Authenticate';

  @override
  String get security => 'Security';

  @override
  String get biometricUnlock => 'Biometric unlock';

  @override
  String get biometricUnlockSubtitle => 'Require biometrics to open the app';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get noPendingBookings => 'No pending bookings';

  @override
  String get noConfirmedBookings => 'No confirmed bookings';

  @override
  String get noBookingsYet => 'No bookings yet';

  @override
  String get resultMarkedDelivered => 'Result marked as delivered';

  @override
  String get actions => 'Actions';

  @override
  String get confirm => 'Confirm';

  @override
  String get trackingNumberLabel => 'Tracking Number';

  @override
  String get enterTrackingNumberOptional => 'Enter tracking number (optional)';

  @override
  String get markResultDelivered => 'Mark Result Delivered';

  @override
  String bookingMarkedAs(String status) {
    return 'Booking $status';
  }

  @override
  String kitStatusUpdatedTo(String status) {
    return 'Kit status updated to $status';
  }

  @override
  String markAs(String status) {
    return 'Mark as $status';
  }

  @override
  String get slotCapacityUsage => 'Slot Capacity Usage';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get mostBookedTests => 'Most Booked Tests';

  @override
  String prepLabel(String preparation) {
    return 'Prep: $preparation';
  }

  @override
  String shareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String pendingBookingsAwaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookings awaiting confirmation',
      one: '1 booking awaiting confirmation',
    );
    return '$_temp0';
  }

  @override
  String get capacityUsageSubtitle =>
      'Percentage of upcoming slots with confirmed bookings';

  @override
  String get reviewsWillAppear =>
      'Patient reviews will appear here after they\'re published';

  @override
  String startingFromEgp(Object price) {
    return 'From $price EGP';
  }

  @override
  String get assistantTitle => 'Health Assistant';

  @override
  String get assistantNewChat => 'New chat';

  @override
  String get assistantInputHint => 'Ask about a test, prep, or your health…';

  @override
  String get assistantEmptyTitle => 'Hi! I\'m your health assistant';

  @override
  String get assistantEmptyBody =>
      'Ask me about lab tests, how to prepare, or what a result generally means. I can\'t replace a doctor\'s advice.';

  @override
  String get assistantDisclaimer =>
      'AI assistant — not a substitute for professional medical advice.';

  @override
  String get assistantSuggestion1 =>
      'How do I prepare for a fasting blood test?';

  @override
  String get assistantSuggestion2 => 'What does a CBC test measure?';

  @override
  String get assistantSuggestion3 => 'What is HbA1c used for?';
}
