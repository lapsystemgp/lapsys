// Smoke test — verifies the app boots without crashing.
// Full feature tests live in test/features/.

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/features/auth/application/session_notifier.dart';
import 'package:testly/features/auth/presentation/login_screen.dart';
import 'package:testly/l10n/app_localizations.dart';

class _FakeSession extends SessionNotifier {
  @override
  Future<void> restore() async {}
  @override
  Future<void> login({required String email, required String password, required String selectedRole}) async {}
  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('LoginScreen renders without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionNotifierProvider.overrideWith(() => _FakeSession()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TesTly'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}
