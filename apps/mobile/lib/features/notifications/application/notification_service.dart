import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../../core/router/app_router.dart';
import '../data/notification_repository.dart';

// Provider that stores a deep-link route from a notification tap before the
// router is mounted (terminated-app cold start). The router redirect clears
// and consumes it on first evaluation.
final pendingNotificationRouteProvider = StateProvider<String?>((ref) => null);

const _androidGeneralChannel = AndroidNotificationChannel(
  'testly_general',
  'TesTly Updates',
  description: 'Booking confirmations, results, and kit-status alerts.',
  importance: Importance.high,
);

const _androidReminderChannel = AndroidNotificationChannel(
  'testly_reminders',
  'Test Reminders',
  description: 'Pre-test preparation reminders the evening before your test.',
  importance: Importance.high,
);

class NotificationService {
  NotificationService(this._ref);
  final Ref _ref;

  final _localPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _fcmAvailable = false;

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    await _initLocalNotifications();
    await _initFcm();
  }

  Future<void> _initLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          _localNotificationBackgroundHandler,
    );

    final androidPlugin =
        _localPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin
        ?.createNotificationChannel(_androidGeneralChannel);
    await androidPlugin
        ?.createNotificationChannel(_androidReminderChannel);
  }

  Future<void> _initFcm() async {
    try {
      // Background message handler is registered in main.dart (must be top-level).
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

      // Terminated-state tap: store pending route, consumed by router redirect.
      final initial =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        final route = _payloadToRoute(initial.data);
        if (route != null) {
          _ref.read(pendingNotificationRouteProvider.notifier).state = route;
        }
      }

      FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

      // Suppress native foreground banners on iOS — we show our own.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );

      _fcmAvailable = true;
    } catch (_) {
      // Firebase not configured or unavailable — push notifications disabled.
    }
  }

  // ─── Foreground push display ───────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localPlugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidGeneralChannel.id,
          _androidGeneralChannel.name,
          channelDescription: _androidGeneralChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _payloadToRoute(message.data),
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null) _navigateTo(route);
  }

  // ─── Background tap (FCM) ─────────────────────────────────────────────────

  void _onNotificationTap(RemoteMessage message) {
    final route = _payloadToRoute(message.data);
    if (route != null) _navigateTo(route);
  }

  // ─── Routing ──────────────────────────────────────────────────────────────

  void _navigateTo(String route) {
    try {
      _ref.read(appRouterProvider).go(route);
    } catch (_) {
      // Router not yet mounted — store for redirect.
      _ref.read(pendingNotificationRouteProvider.notifier).state = route;
    }
  }

  String? _payloadToRoute(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = (data['id'] ?? data['bookingId']) as String?;
    if (type == null || id == null) return null;
    return switch (type) {
      'booking' => '/patient/bookings/$id',
      'result' => '/patient/results/$id',
      _ => null,
    };
  }

  // ─── Device registration ──────────────────────────────────────────────────

  Future<void> registerDeviceForUser() async {
    if (!_fcmAvailable) return;
    try {
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission();
        await FirebaseMessaging.instance.getAPNSToken();
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _ref.read(notificationRepositoryProvider).registerDevice(
            fcmToken: token,
            platform: Platform.isIOS ? 'ios' : 'android',
          );
    } catch (_) {
      // Non-fatal — push simply won't work for this session.
    }
  }

  Future<void> unregisterDevice() async {
    if (!_fcmAvailable) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _ref.read(notificationRepositoryProvider).removeDevice(token);
    } catch (_) {
      // Best-effort on logout.
    }
  }

  void _onTokenRefresh(String newToken) {
    _ref.read(notificationRepositoryProvider).registerDevice(
          fcmToken: newToken,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
  }

  // ─── Permission ───────────────────────────────────────────────────────────

  Future<AuthorizationStatus> getPermissionStatus() async {
    if (!_fcmAvailable) return AuthorizationStatus.notDetermined;
    final settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<bool> requestPermission() async {
    if (!_fcmAvailable) return false;
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (granted) await registerDeviceForUser();
    return granted;
  }

  // ─── Prep reminders ───────────────────────────────────────────────────────

  Future<void> schedulePrepReminder({
    required String bookingId,
    required String testName,
    required String preparation,
    required DateTime scheduledAt,
  }) async {
    // Remind at 20:00 the evening before the test.
    final reminderWall = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day - 1,
      20,
    );
    if (!reminderWall.isAfter(DateTime.now())) return;

    final tzReminder = tz.TZDateTime.from(reminderWall, tz.local);
    final id = bookingId.hashCode.abs();

    await _localPlugin.zonedSchedule(
      id,
      "Prepare for tomorrow's test",
      '$testName: $preparation',
      tzReminder,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidReminderChannel.id,
          _androidReminderChannel.name,
          channelDescription: _androidReminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      payload: '/patient/bookings/$bookingId',
    );
  }

  Future<void> cancelPrepReminder(String bookingId) async {
    await _localPlugin.cancel(bookingId.hashCode.abs());
  }
}

// Top-level callback required by flutter_local_notifications for background
// notification responses (e.g. tapping a prep reminder when app is terminated).
// Routing is not possible here — the pending route is picked up on next launch
// via pendingNotificationRouteProvider in the notification service init.
@pragma('vm:entry-point')
void _localNotificationBackgroundHandler(NotificationResponse response) {
  // Intentionally empty: payload routing on terminated-state taps is handled
  // via FirebaseMessaging.instance.getInitialMessage() in NotificationService.
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});
