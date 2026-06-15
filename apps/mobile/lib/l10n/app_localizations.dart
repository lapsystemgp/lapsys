import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'TesTly'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueAsPatient.
  ///
  /// In en, this message translates to:
  /// **'Continue as Patient'**
  String get continueAsPatient;

  /// No description provided for @continueAsLab.
  ///
  /// In en, this message translates to:
  /// **'Continue as Lab'**
  String get continueAsLab;

  /// No description provided for @rolePatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// No description provided for @roleLab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get roleLab;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get biometricPrompt;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to unlock TesTly'**
  String get biometricReason;

  /// No description provided for @labPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Pending Approval'**
  String get labPendingTitle;

  /// No description provided for @labPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your lab account is under review. You\'ll be notified once approved.'**
  String get labPendingBody;

  /// No description provided for @adminMobileUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Admin panel is available on the web only.'**
  String get adminMobileUnsupported;

  /// No description provided for @openWebApp.
  ///
  /// In en, this message translates to:
  /// **'Open Web App'**
  String get openWebApp;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @patientTabLabs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get patientTabLabs;

  /// No description provided for @patientTabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get patientTabBookings;

  /// No description provided for @patientTabResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get patientTabResults;

  /// No description provided for @patientTabTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get patientTabTrends;

  /// No description provided for @patientTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get patientTabProfile;

  /// No description provided for @labTabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get labTabDashboard;

  /// No description provided for @labTabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get labTabAnalytics;

  /// No description provided for @labTabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get labTabReviews;

  /// No description provided for @labTabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get labTabBookings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @labName.
  ///
  /// In en, this message translates to:
  /// **'Lab Name'**
  String get labName;

  /// No description provided for @registerPatient.
  ///
  /// In en, this message translates to:
  /// **'Register as Patient'**
  String get registerPatient;

  /// No description provided for @registerLab.
  ///
  /// In en, this message translates to:
  /// **'Register as Lab'**
  String get registerLab;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egp;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordLength;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @viewLab.
  ///
  /// In en, this message translates to:
  /// **'View Lab'**
  String get viewLab;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot'**
  String get slot;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @homeCollection.
  ///
  /// In en, this message translates to:
  /// **'Home collection'**
  String get homeCollection;

  /// No description provided for @homeTestKit.
  ///
  /// In en, this message translates to:
  /// **'Home Test Kit'**
  String get homeTestKit;

  /// No description provided for @labVisit.
  ///
  /// In en, this message translates to:
  /// **'Lab Visit'**
  String get labVisit;

  /// No description provided for @homeCollectionOnly.
  ///
  /// In en, this message translates to:
  /// **'Home collection only'**
  String get homeCollectionOnly;

  /// No description provided for @findTestOrLab.
  ///
  /// In en, this message translates to:
  /// **'Find a Test or Lab'**
  String get findTestOrLab;

  /// No description provided for @labFilters.
  ///
  /// In en, this message translates to:
  /// **'Lab filters'**
  String get labFilters;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tests (e.g. CBC) or labs…'**
  String get searchHint;

  /// No description provided for @testsTab.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get testsTab;

  /// No description provided for @labsTab.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get labsTab;

  /// No description provided for @bestRating.
  ///
  /// In en, this message translates to:
  /// **'Best rating'**
  String get bestRating;

  /// No description provided for @lowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get lowestPrice;

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// No description provided for @noTestsFound.
  ///
  /// In en, this message translates to:
  /// **'No tests found'**
  String get noTestsFound;

  /// No description provided for @tryDifferentTestName.
  ///
  /// In en, this message translates to:
  /// **'Try a different test name'**
  String get tryDifferentTestName;

  /// No description provided for @noLabsFound.
  ///
  /// In en, this message translates to:
  /// **'No labs found'**
  String get noLabsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @fromPriceEgp.
  ///
  /// In en, this message translates to:
  /// **'From {price} EGP'**
  String fromPriceEgp(String price);

  /// No description provided for @labCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lab} other{{count} labs}}'**
  String labCount(int count);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @labsOfferingTest.
  ///
  /// In en, this message translates to:
  /// **'Labs offering {testName}'**
  String labsOfferingTest(String testName);

  /// No description provided for @noLabsOfferTest.
  ///
  /// In en, this message translates to:
  /// **'No labs offer this test yet'**
  String get noLabsOfferTest;

  /// No description provided for @resultsIn.
  ///
  /// In en, this message translates to:
  /// **'Results in {turnaround}'**
  String resultsIn(String turnaround);

  /// No description provided for @parametersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 parameter} other{{count} parameters}}'**
  String parametersCount(int count);

  /// No description provided for @atLabsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{At 1 lab} other{At {count} labs}}'**
  String atLabsCount(int count);

  /// No description provided for @enableLocationForSort.
  ///
  /// In en, this message translates to:
  /// **'Enable location to sort labs by how near they are.'**
  String get enableLocationForSort;

  /// No description provided for @noTestsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tests available'**
  String get noTestsAvailable;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @chooseBookingType.
  ///
  /// In en, this message translates to:
  /// **'Choose booking type'**
  String get chooseBookingType;

  /// No description provided for @chooseTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose a time slot'**
  String get chooseTimeSlot;

  /// No description provided for @enterHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter home address'**
  String get enterHomeAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @confirmBookingStep.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBookingStep;

  /// No description provided for @processingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processingEllipsis;

  /// No description provided for @bookingConfirmedBang.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get bookingConfirmedBang;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingFailed;

  /// No description provided for @howToTakeTest.
  ///
  /// In en, this message translates to:
  /// **'How would you like to take this test?'**
  String get howToTakeTest;

  /// No description provided for @visitLabInPerson.
  ///
  /// In en, this message translates to:
  /// **'Visit the lab in person'**
  String get visitLabInPerson;

  /// No description provided for @phlebotomistVisitsHome.
  ///
  /// In en, this message translates to:
  /// **'A phlebotomist visits your home'**
  String get phlebotomistVisitsHome;

  /// No description provided for @kitShippedSelfCollect.
  ///
  /// In en, this message translates to:
  /// **'Kit shipped to you; self-collect sample'**
  String get kitShippedSelfCollect;

  /// No description provided for @noSlotsAvailable7Days.
  ///
  /// In en, this message translates to:
  /// **'No slots available in the next 7 days'**
  String get noSlotsAvailable7Days;

  /// No description provided for @continueWithoutSlot.
  ///
  /// In en, this message translates to:
  /// **'Continue without a slot'**
  String get continueWithoutSlot;

  /// No description provided for @enterAddressForService.
  ///
  /// In en, this message translates to:
  /// **'Enter the address for the service:'**
  String get enterAddressForService;

  /// No description provided for @homeAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get homeAddressLabel;

  /// No description provided for @streetApartmentCityHint.
  ///
  /// In en, this message translates to:
  /// **'Street, apartment, city…'**
  String get streetApartmentCityHint;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @paymentOnlineDemo.
  ///
  /// In en, this message translates to:
  /// **'Online (demo)'**
  String get paymentOnlineDemo;

  /// No description provided for @paymentCashAtLab.
  ///
  /// In en, this message translates to:
  /// **'Cash at lab'**
  String get paymentCashAtLab;

  /// No description provided for @paymentCashOnCollection.
  ///
  /// In en, this message translates to:
  /// **'Cash on collection'**
  String get paymentCashOnCollection;

  /// No description provided for @paymentCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get paymentCashOnDelivery;

  /// No description provided for @bookingCreatedFor.
  ///
  /// In en, this message translates to:
  /// **'Your booking for {testName} at {labName} has been created.'**
  String bookingCreatedFor(String testName, String labName);

  /// No description provided for @viewMyBookings.
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get viewMyBookings;

  /// No description provided for @backToLabs.
  ///
  /// In en, this message translates to:
  /// **'Back to Labs'**
  String get backToLabs;

  /// No description provided for @confirmBookingButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBookingButton;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get noUpcomingBookings;

  /// No description provided for @noPastBookings.
  ///
  /// In en, this message translates to:
  /// **'No past bookings'**
  String get noPastBookings;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @bookingDetail.
  ///
  /// In en, this message translates to:
  /// **'Booking Detail'**
  String get bookingDetail;

  /// No description provided for @cancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancel failed: {error}'**
  String cancelFailed(String error);

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailedMsg(String error);

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @retryPayment.
  ///
  /// In en, this message translates to:
  /// **'Retry Payment'**
  String get retryPayment;

  /// No description provided for @payStatus.
  ///
  /// In en, this message translates to:
  /// **'Pay status'**
  String get payStatus;

  /// No description provided for @payStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get payStatusPending;

  /// No description provided for @payStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payStatusPaid;

  /// No description provided for @payStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get payStatusFailed;

  /// No description provided for @payStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get payStatusRefunded;

  /// No description provided for @kitTracking.
  ///
  /// In en, this message translates to:
  /// **'Kit Tracking'**
  String get kitTracking;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking #{number}'**
  String trackingNumber(String number);

  /// No description provided for @awaitingShipment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting shipment'**
  String get awaitingShipment;

  /// No description provided for @kitShipped.
  ///
  /// In en, this message translates to:
  /// **'Kit shipped'**
  String get kitShipped;

  /// No description provided for @kitDelivered.
  ///
  /// In en, this message translates to:
  /// **'Kit delivered'**
  String get kitDelivered;

  /// No description provided for @sampleReceived.
  ///
  /// In en, this message translates to:
  /// **'Sample received'**
  String get sampleReceived;

  /// No description provided for @statusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status History'**
  String get statusHistory;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get personalInfo;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @shareHistoryAcrossLabs.
  ///
  /// In en, this message translates to:
  /// **'Share history across labs'**
  String get shareHistoryAcrossLabs;

  /// No description provided for @enableCrossLabTrends.
  ///
  /// In en, this message translates to:
  /// **'Enable cross-lab health trends and comparisons'**
  String get enableCrossLabTrends;

  /// No description provided for @allLabsSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'All labs you have tested with can see your full history to power trend charts.'**
  String get allLabsSeeHistory;

  /// No description provided for @onlyTestingLabSeesResult.
  ///
  /// In en, this message translates to:
  /// **'Only the lab that performed a test can see that result.'**
  String get onlyTestingLabSeesResult;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(String error);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @myResults.
  ///
  /// In en, this message translates to:
  /// **'My Results'**
  String get myResults;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;

  /// No description provided for @completedTestsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Completed tests will appear here'**
  String get completedTestsWillAppear;

  /// No description provided for @resultStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get resultStatusPending;

  /// No description provided for @resultStatusUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get resultStatusUploaded;

  /// No description provided for @resultStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get resultStatusDelivered;

  /// No description provided for @resultStatusStructured.
  ///
  /// In en, this message translates to:
  /// **'Structured'**
  String get resultStatusStructured;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @resultDetail.
  ///
  /// In en, this message translates to:
  /// **'Result Detail'**
  String get resultDetail;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience at {labName}'**
  String rateExperience(String labName);

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted!'**
  String get reviewSubmitted;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit: {error}'**
  String failedToSubmit(String error);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @couldNotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not open document: {error}'**
  String couldNotOpenDocument(String error);

  /// No description provided for @healthTrends.
  ///
  /// In en, this message translates to:
  /// **'Health Trends'**
  String get healthTrends;

  /// No description provided for @period3mo.
  ///
  /// In en, this message translates to:
  /// **'3 mo'**
  String get period3mo;

  /// No description provided for @period6mo.
  ///
  /// In en, this message translates to:
  /// **'6 mo'**
  String get period6mo;

  /// No description provided for @period12mo.
  ///
  /// In en, this message translates to:
  /// **'12 mo'**
  String get period12mo;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get periodAll;

  /// No description provided for @byAnalyte.
  ///
  /// In en, this message translates to:
  /// **'By Analyte'**
  String get byAnalyte;

  /// No description provided for @byTest.
  ///
  /// In en, this message translates to:
  /// **'By Test'**
  String get byTest;

  /// No description provided for @noTrendsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No trends in the selected period. Try a wider time range.'**
  String get noTrendsInPeriod;

  /// No description provided for @noStructuredDataYet.
  ///
  /// In en, this message translates to:
  /// **'No structured data yet'**
  String get noStructuredDataYet;

  /// No description provided for @structuredDataExplanation.
  ///
  /// In en, this message translates to:
  /// **'When labs enter your test values as structured data, trends and charts will appear here.'**
  String get structuredDataExplanation;

  /// No description provided for @recentReadings.
  ///
  /// In en, this message translates to:
  /// **'Recent readings'**
  String get recentReadings;

  /// No description provided for @trendRising.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get trendRising;

  /// No description provided for @trendFalling.
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get trendFalling;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @trendNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get trendNotEnoughData;

  /// No description provided for @pdfOnlyResults.
  ///
  /// In en, this message translates to:
  /// **'PDF-only results'**
  String get pdfOnlyResults;

  /// No description provided for @pdfOnlyResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'These results have a PDF but no structured data for trending.'**
  String get pdfOnlyResultsDesc;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @totalBookings.
  ///
  /// In en, this message translates to:
  /// **'Total Bookings'**
  String get totalBookings;

  /// No description provided for @pendingResults.
  ///
  /// In en, this message translates to:
  /// **'Pending Results'**
  String get pendingResults;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @slotCapacityUsed.
  ///
  /// In en, this message translates to:
  /// **'Slot Capacity Used'**
  String get slotCapacityUsed;

  /// No description provided for @labStaffCollectSamples.
  ///
  /// In en, this message translates to:
  /// **'Lab staff collect samples at patient\'s home'**
  String get labStaffCollectSamples;

  /// No description provided for @shipKitToPatientAddress.
  ///
  /// In en, this message translates to:
  /// **'Ship kit to patient\'s address'**
  String get shipKitToPatientAddress;

  /// No description provided for @saveCapabilities.
  ///
  /// In en, this message translates to:
  /// **'Save Capabilities'**
  String get saveCapabilities;

  /// No description provided for @capabilitiesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Capabilities updated'**
  String get capabilitiesUpdated;

  /// No description provided for @capabilities.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get capabilities;

  /// No description provided for @failedWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedWithError(String error);

  /// No description provided for @stayUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Stay up to date'**
  String get stayUpToDate;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Get instant alerts when your booking is confirmed, results are ready, or your kit ships — and reminders the evening before tests that need preparation.'**
  String get notificationPermissionBody;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock TesTly'**
  String get authenticateToUnlock;

  /// No description provided for @authenticateButton.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticateButton;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require biometrics to open the app'**
  String get biometricUnlockSubtitle;

  /// No description provided for @noPendingBookings.
  ///
  /// In en, this message translates to:
  /// **'No pending bookings'**
  String get noPendingBookings;

  /// No description provided for @noConfirmedBookings.
  ///
  /// In en, this message translates to:
  /// **'No confirmed bookings'**
  String get noConfirmedBookings;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookingsYet;

  /// No description provided for @resultMarkedDelivered.
  ///
  /// In en, this message translates to:
  /// **'Result marked as delivered'**
  String get resultMarkedDelivered;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @trackingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumberLabel;

  /// No description provided for @enterTrackingNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking number (optional)'**
  String get enterTrackingNumberOptional;

  /// No description provided for @markResultDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark Result Delivered'**
  String get markResultDelivered;

  /// No description provided for @bookingMarkedAs.
  ///
  /// In en, this message translates to:
  /// **'Booking {status}'**
  String bookingMarkedAs(String status);

  /// No description provided for @kitStatusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Kit status updated to {status}'**
  String kitStatusUpdatedTo(String status);

  /// No description provided for @markAs.
  ///
  /// In en, this message translates to:
  /// **'Mark as {status}'**
  String markAs(String status);

  /// No description provided for @slotCapacityUsage.
  ///
  /// In en, this message translates to:
  /// **'Slot Capacity Usage'**
  String get slotCapacityUsage;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @mostBookedTests.
  ///
  /// In en, this message translates to:
  /// **'Most Booked Tests'**
  String get mostBookedTests;

  /// No description provided for @prepLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep: {preparation}'**
  String prepLabel(String preparation);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  /// No description provided for @pendingBookingsAwaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 booking awaiting confirmation} other{{count} bookings awaiting confirmation}}'**
  String pendingBookingsAwaiting(int count);

  /// No description provided for @capacityUsageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage of upcoming slots with confirmed bookings'**
  String get capacityUsageSubtitle;

  /// No description provided for @reviewsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Patient reviews will appear here after they\'re published'**
  String get reviewsWillAppear;

  /// No description provided for @startingFromEgp.
  ///
  /// In en, this message translates to:
  /// **'From {price} EGP'**
  String startingFromEgp(Object price);

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Assistant'**
  String get assistantTitle;

  /// No description provided for @assistantNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get assistantNewChat;

  /// No description provided for @assistantInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about a test, prep, or your health…'**
  String get assistantInputHint;

  /// No description provided for @assistantEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your health assistant'**
  String get assistantEmptyTitle;

  /// No description provided for @assistantEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Ask me about lab tests, how to prepare, or what a result generally means. I can\'t replace a doctor\'s advice.'**
  String get assistantEmptyBody;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI assistant — not a substitute for professional medical advice.'**
  String get assistantDisclaimer;

  /// No description provided for @assistantSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I prepare for a fasting blood test?'**
  String get assistantSuggestion1;

  /// No description provided for @assistantSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'What does a CBC test measure?'**
  String get assistantSuggestion2;

  /// No description provided for @assistantSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'What is HbA1c used for?'**
  String get assistantSuggestion3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
