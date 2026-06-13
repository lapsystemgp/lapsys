import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/features/auth/application/session_notifier.dart';
import 'package:testly/features/auth/presentation/login_screen.dart';
import 'package:testly/l10n/app_localizations.dart';

// ─── Fake SessionNotifier ─────────────────────────────────────────────────────

class FakeSessionNotifier extends SessionNotifier {
  bool loginCalled = false;
  String? lastEmail;
  String? lastRole;
  Exception? throwOnLogin;

  @override
  Future<void> restore() async {}

  @override
  Future<void> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    loginCalled = true;
    lastEmail = email;
    lastRole = selectedRole;
    if (throwOnLogin != null) throw throwOnLogin!;
    state = const SessionState(status: SessionStatus.authenticated);
  }

  @override
  Future<void> logout() async {}
}

// ─── Widget harness ──────────────────────────────────────────────────────────

Widget _harness(FakeSessionNotifier notifier) {
  return ProviderScope(
    overrides: [
      sessionNotifierProvider.overrideWith(() => notifier),
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
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late FakeSessionNotifier notifier;

  setUp(() {
    notifier = FakeSessionNotifier();
  });

  testWidgets('renders email and password fields with a login button', (tester) async {
    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('shows a role toggle with Patient and Lab segments', (tester) async {
    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Lab'), findsOneWidget);
    // SegmentedButton uses a private enum type — match by widget predicate.
    expect(
      find.byWidgetPredicate((w) => w is SegmentedButton),
      findsOneWidget,
    );
  });

  testWidgets('shows validation errors when form is submitted empty', (tester) async {
    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    final loginBtns = find.text('Login');
    final elevated = find.ancestor(
      of: loginBtns.last,
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(elevated);
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsAtLeast(1));
    expect(notifier.loginCalled, false);
  });

  testWidgets('calls SessionNotifier.login with correct email and role', (tester) async {
    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'patient@testly.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password123',
    );

    final elevated = find.ancestor(
      of: find.text('Login').last,
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(elevated);
    await tester.pump();

    expect(notifier.loginCalled, true);
    expect(notifier.lastEmail, 'patient@testly.com');
    expect(notifier.lastRole, 'patient');
  });

  testWidgets('switching to Lab segment sends role "lab"', (tester) async {
    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'lab@testly.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password123',
    );

    final elevated = find.ancestor(
      of: find.text('Login').last,
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(elevated);
    await tester.pump();

    expect(notifier.lastRole, 'lab');
  });

  testWidgets('displays error message returned by the notifier', (tester) async {
    notifier.throwOnLogin =
        Exception('ApiException(401): Invalid credentials');

    await tester.pumpWidget(_harness(notifier));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'bad@bad.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass1');

    final elevated = find.ancestor(
      of: find.text('Login').last,
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(elevated);
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid credentials'), findsOneWidget);
  });
}
