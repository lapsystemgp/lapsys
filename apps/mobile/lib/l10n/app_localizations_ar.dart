// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تيستلي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get continueAsPatient => 'المتابعة كمريض';

  @override
  String get continueAsLab => 'المتابعة كمعمل';

  @override
  String get rolePatient => 'مريض';

  @override
  String get roleLab => 'معمل';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get biometricPrompt => 'المصادقة للمتابعة';

  @override
  String get biometricReason => 'استخدم بصمتك لفتح تيستلي';

  @override
  String get labPendingTitle => 'الحساب قيد المراجعة';

  @override
  String get labPendingBody =>
      'حساب معملك قيد المراجعة. سيتم إخطارك عند الموافقة.';

  @override
  String get adminMobileUnsupported => 'لوحة الإدارة متاحة على الويب فقط.';

  @override
  String get openWebApp => 'افتح تطبيق الويب';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get error => 'حدث خطأ ما';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get patientTabLabs => 'المعامل';

  @override
  String get patientTabBookings => 'الحجوزات';

  @override
  String get patientTabResults => 'النتائج';

  @override
  String get patientTabTrends => 'الاتجاهات';

  @override
  String get patientTabProfile => 'الملف الشخصي';

  @override
  String get labTabDashboard => 'لوحة التحكم';

  @override
  String get labTabAnalytics => 'التحليلات';

  @override
  String get labTabReviews => 'التقييمات';

  @override
  String get labTabBookings => 'الحجوزات';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get labName => 'اسم المعمل';

  @override
  String get registerPatient => 'التسجيل كمريض';

  @override
  String get registerLab => 'التسجيل كمعمل';

  @override
  String get egp => 'ج.م';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get validationPasswordLength =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get apply => 'تطبيق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get continueAction => 'متابعة';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get book => 'احجز';

  @override
  String get viewLab => 'عرض المعمل';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get enable => 'تفعيل';

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get total => 'المجموع';

  @override
  String get payment => 'الدفع';

  @override
  String get typeLabel => 'النوع';

  @override
  String get price => 'السعر';

  @override
  String get rating => 'التقييم';

  @override
  String get slot => 'الموعد';

  @override
  String get document => 'المستند';

  @override
  String get homeCollection => 'تحصيل منزلي';

  @override
  String get homeTestKit => 'عدة فحص منزلية';

  @override
  String get labVisit => 'زيارة المعمل';

  @override
  String get homeCollectionOnly => 'تحصيل منزلي فقط';

  @override
  String get findTestOrLab => 'ابحث عن تحليل أو معمل';

  @override
  String get labFilters => 'فلاتر المعامل';

  @override
  String get searchHint => 'ابحث عن تحليل (مثل CBC) أو معمل...';

  @override
  String get testsTab => 'التحاليل';

  @override
  String get labsTab => 'المعامل';

  @override
  String get bestRating => 'أعلى تقييم';

  @override
  String get lowestPrice => 'أقل سعر';

  @override
  String get nearest => 'الأقرب';

  @override
  String get noTestsFound => 'لا توجد تحاليل';

  @override
  String get tryDifferentTestName => 'جرب اسمًا آخر للتحليل';

  @override
  String get noLabsFound => 'لا توجد معامل';

  @override
  String get tryAdjustingFilters => 'حاول تعديل البحث أو الفلاتر';

  @override
  String fromPriceEgp(String price) {
    return 'من $price ج.م';
  }

  @override
  String labCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معامل',
      one: 'معمل واحد',
    );
    return '$_temp0';
  }

  @override
  String distanceKm(String distance) {
    return '$distance كم';
  }

  @override
  String labsOfferingTest(String testName) {
    return 'معامل تقدم $testName';
  }

  @override
  String get noLabsOfferTest => 'لا توجد معامل تقدم هذا التحليل بعد';

  @override
  String resultsIn(String turnaround) {
    return 'النتائج خلال $turnaround';
  }

  @override
  String parametersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملات',
      one: 'معامل واحد',
    );
    return '$_temp0';
  }

  @override
  String atLabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'في $count معامل',
      one: 'في معمل واحد',
    );
    return '$_temp0';
  }

  @override
  String get enableLocationForSort => 'فعّل الموقع لترتيب المعامل حسب القرب.';

  @override
  String get noTestsAvailable => 'لا توجد تحاليل متاحة';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get chooseBookingType => 'اختر نوع الحجز';

  @override
  String get chooseTimeSlot => 'اختر موعدًا';

  @override
  String get enterHomeAddress => 'أدخل عنوان المنزل';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get confirmBookingStep => 'تأكيد الحجز';

  @override
  String get processingEllipsis => 'جارٍ المعالجة…';

  @override
  String get bookingConfirmedBang => 'تم تأكيد الحجز!';

  @override
  String get bookingFailed => 'فشل الحجز';

  @override
  String get howToTakeTest => 'كيف تريد إجراء هذا التحليل؟';

  @override
  String get visitLabInPerson => 'زيارة المعمل شخصيًا';

  @override
  String get phlebotomistVisitsHome => 'يزورك أخصائي سحب عينات في المنزل';

  @override
  String get kitShippedSelfCollect => 'عدة ترسل إليك لسحب العينة بنفسك';

  @override
  String get noSlotsAvailable7Days => 'لا توجد مواعيد متاحة خلال 7 أيام';

  @override
  String get continueWithoutSlot => 'المتابعة بدون موعد';

  @override
  String get enterAddressForService => 'أدخل العنوان للخدمة:';

  @override
  String get homeAddressLabel => 'عنوان المنزل';

  @override
  String get streetApartmentCityHint => 'الشارع، الشقة، المدينة...';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get paymentOnlineDemo => 'أونلاين (تجريبي)';

  @override
  String get paymentCashAtLab => 'نقدًا في المعمل';

  @override
  String get paymentCashOnCollection => 'نقدًا عند التحصيل';

  @override
  String get paymentCashOnDelivery => 'نقدًا عند التسليم';

  @override
  String bookingCreatedFor(String testName, String labName) {
    return 'تم إنشاء حجزك لـ $testName في $labName.';
  }

  @override
  String get viewMyBookings => 'عرض حجوزاتي';

  @override
  String get backToLabs => 'العودة إلى المعامل';

  @override
  String get confirmBookingButton => 'تأكيد الحجز';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get upcoming => 'القادمة';

  @override
  String get past => 'السابقة';

  @override
  String get noUpcomingBookings => 'لا توجد حجوزات قادمة';

  @override
  String get noPastBookings => 'لا توجد حجوزات سابقة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get bookingDetail => 'تفاصيل الحجز';

  @override
  String cancelFailed(String error) {
    return 'فشل الإلغاء: $error';
  }

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح!';

  @override
  String paymentFailedMsg(String error) {
    return 'فشل الدفع: $error';
  }

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get retryPayment => 'إعادة محاولة الدفع';

  @override
  String get payStatus => 'حالة الدفع';

  @override
  String get payStatusPending => 'قيد الانتظار';

  @override
  String get payStatusPaid => 'مدفوع';

  @override
  String get payStatusFailed => 'فاشل';

  @override
  String get payStatusRefunded => 'مسترد';

  @override
  String get kitTracking => 'تتبع العدة';

  @override
  String trackingNumber(String number) {
    return 'رقم التتبع: $number';
  }

  @override
  String get awaitingShipment => 'في انتظار الشحن';

  @override
  String get kitShipped => 'تم شحن العدة';

  @override
  String get kitDelivered => 'تم تسليم العدة';

  @override
  String get sampleReceived => 'تم استلام العينة';

  @override
  String get statusHistory => 'سجل الحالات';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get account => 'الحساب';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get shareHistoryAcrossLabs => 'مشاركة السجل عبر المعامل';

  @override
  String get enableCrossLabTrends => 'تفعيل الاتجاهات الصحية عبر المعامل';

  @override
  String get allLabsSeeHistory =>
      'جميع المعامل التي أجريت بها اختبارات يمكنها رؤية سجلك الكامل لدعم مخططات الاتجاهات.';

  @override
  String get onlyTestingLabSeesResult =>
      'فقط المعمل الذي أجرى الاختبار يمكنه رؤية النتيجة.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String saveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get myResults => 'نتائجي';

  @override
  String get noResultsYet => 'لا توجد نتائج بعد';

  @override
  String get completedTestsWillAppear => 'ستظهر الاختبارات المكتملة هنا';

  @override
  String get resultStatusPending => 'قيد الانتظار';

  @override
  String get resultStatusUploaded => 'مرفوع';

  @override
  String get resultStatusDelivered => 'مسلّم';

  @override
  String get resultStatusStructured => 'منظم';

  @override
  String get result => 'النتيجة';

  @override
  String get resultDetail => 'تفاصيل النتيجة';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get writeReview => 'كتابة تقييم';

  @override
  String rateExperience(String labName) {
    return 'قيّم تجربتك في $labName';
  }

  @override
  String get commentOptional => 'تعليق (اختياري)';

  @override
  String get reviewSubmitted => 'تم إرسال التقييم!';

  @override
  String failedToSubmit(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get summary => 'ملخص';

  @override
  String get yourReview => 'تقييمك';

  @override
  String couldNotOpenDocument(String error) {
    return 'تعذر فتح المستند: $error';
  }

  @override
  String get healthTrends => 'الاتجاهات الصحية';

  @override
  String get period3mo => '3 أشهر';

  @override
  String get period6mo => '6 أشهر';

  @override
  String get period12mo => '12 شهرًا';

  @override
  String get periodAll => 'الكل';

  @override
  String get byAnalyte => 'حسب المحلل';

  @override
  String get byTest => 'حسب الاختبار';

  @override
  String get noTrendsInPeriod =>
      'لا توجد اتجاهات في الفترة المحددة. حاول توسيع النطاق الزمني.';

  @override
  String get noStructuredDataYet => 'لا توجد بيانات منظمة بعد';

  @override
  String get structuredDataExplanation =>
      'عندما تدخل المعامل قيم اختباراتك كبيانات منظمة، ستظهر الاتجاهات والرسوم البيانية هنا.';

  @override
  String get recentReadings => 'القراءات الأخيرة';

  @override
  String get trendRising => 'مرتفع';

  @override
  String get trendFalling => 'منخفض';

  @override
  String get trendStable => 'مستقر';

  @override
  String get trendNotEnoughData => 'بيانات غير كافية';

  @override
  String get pdfOnlyResults => 'نتائج PDF فقط';

  @override
  String get pdfOnlyResultsDesc =>
      'هذه النتائج تحتوي على PDF ولكن لا توجد بيانات منظمة للاتجاهات.';

  @override
  String get low => 'منخفض';

  @override
  String get high => 'مرتفع';

  @override
  String get totalBookings => 'إجمالي الحجوزات';

  @override
  String get pendingResults => 'نتائج قيد الانتظار';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get slotCapacityUsed => 'الطاقة الاستيعابية المستخدمة للمواعيد';

  @override
  String get labStaffCollectSamples =>
      'يجمع طاقم المعمل العينات في منزل المريض';

  @override
  String get shipKitToPatientAddress => 'إرسال العدة إلى عنوان المريض';

  @override
  String get saveCapabilities => 'حفظ الإمكانيات';

  @override
  String get capabilitiesUpdated => 'تم تحديث الإمكانيات';

  @override
  String get capabilities => 'الإمكانيات';

  @override
  String failedWithError(String error) {
    return 'فشل: $error';
  }

  @override
  String get stayUpToDate => 'ابقَ على اطلاع';

  @override
  String get notificationPermissionBody =>
      'احصل على تنبيهات فورية عند تأكيد حجزك أو جاهزية النتائج أو شحن عدتك — وتذكيرات مسائية قبل الاختبارات التي تحتاج إعدادًا.';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get authenticateToUnlock => 'المصادقة لفتح تيستلي';

  @override
  String get authenticateButton => 'المصادقة';

  @override
  String get security => 'الأمان';

  @override
  String get biometricUnlock => 'الفتح بالبيومترية';

  @override
  String get biometricUnlockSubtitle =>
      'يتطلب المصادقة البيومترية عند فتح التطبيق';

  @override
  String get noPendingBookings => 'لا توجد حجوزات معلقة';

  @override
  String get noConfirmedBookings => 'لا توجد حجوزات مؤكدة';

  @override
  String get noBookingsYet => 'لا توجد حجوزات بعد';

  @override
  String get resultMarkedDelivered => 'تم تحديد النتيجة كمسلّمة';

  @override
  String get actions => 'إجراءات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get trackingNumberLabel => 'رقم التتبع';

  @override
  String get enterTrackingNumberOptional => 'أدخل رقم التتبع (اختياري)';

  @override
  String get markResultDelivered => 'تحديد النتيجة كمُسلَّمة';

  @override
  String bookingMarkedAs(String status) {
    return 'الحجز $status';
  }

  @override
  String kitStatusUpdatedTo(String status) {
    return 'تم تحديث حالة الطقم إلى $status';
  }

  @override
  String markAs(String status) {
    return 'وضع علامة كـ $status';
  }

  @override
  String get slotCapacityUsage => 'استخدام سعة المواعيد';

  @override
  String get completionRate => 'معدل الإكمال';

  @override
  String get mostBookedTests => 'أكثر الفحوصات حجزًا';

  @override
  String prepLabel(String preparation) {
    return 'التحضير: $preparation';
  }

  @override
  String shareFailed(String error) {
    return 'فشلت المشاركة: $error';
  }

  @override
  String pendingBookingsAwaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حجوزات بانتظار التأكيد',
      one: 'حجز واحد بانتظار التأكيد',
    );
    return '$_temp0';
  }

  @override
  String get capacityUsageSubtitle =>
      'نسبة المواعيد القادمة التي تحتوي على حجوزات مؤكدة';

  @override
  String get reviewsWillAppear => 'ستظهر تقييمات المرضى هنا بعد نشرها';

  @override
  String startingFromEgp(Object price) {
    return 'ابتداءً من $price ج.م';
  }
}
