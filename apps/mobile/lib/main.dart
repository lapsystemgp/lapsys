import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/auth/application/session_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase will be initialized in Phase 3 once google-services files are added.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: _AppBoot(),
    ),
  );
}

/// Restores the session before rendering the router-aware App.
class _AppBoot extends ConsumerStatefulWidget {
  const _AppBoot();

  @override
  ConsumerState<_AppBoot> createState() => _AppBootState();
}

class _AppBootState extends ConsumerState<_AppBoot> {
  @override
  void initState() {
    super.initState();
    // Restore stored tokens and validate them in the background.
    Future.microtask(
      () => ref.read(sessionNotifierProvider.notifier).restore(),
    );
  }

  @override
  Widget build(BuildContext context) => const App();
}
