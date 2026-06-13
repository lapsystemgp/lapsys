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
}
