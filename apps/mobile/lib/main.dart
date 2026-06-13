import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/auth/application/session_notifier.dart';
import 'features/notifications/application/notification_service.dart';

// Must be a top-level function. Called by FCM when a message arrives while
// the app is terminated or in the background.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  } catch (_) {
    // Firebase not configured — push notifications are disabled.
    // Replace google-services.json / GoogleService-Info.plist with real
    // Firebase project credentials to enable push.
  }

  runApp(
    const ProviderScope(
      child: _AppBoot(),
    ),
  );
}

class _AppBoot extends ConsumerStatefulWidget {
  const _AppBoot();

  @override
  ConsumerState<_AppBoot> createState() => _AppBootState();
}

class _AppBootState extends ConsumerState<_AppBoot> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Initialize the notification service (sets up FCM listeners, local
      // notifications channels, and checks for a termination-tap initial message).
      await ref.read(notificationServiceProvider).initialize();
      // Restore stored tokens and validate them against /auth/me.
      await ref.read(sessionNotifierProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) => const App();
}
