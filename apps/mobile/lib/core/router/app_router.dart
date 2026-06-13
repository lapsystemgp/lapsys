import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/session_notifier.dart';
import '../../features/auth/data/auth_models.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/lab_pending_screen.dart';
import '../../features/auth/presentation/admin_unsupported_screen.dart';
import '../../features/patient/presentation/patient_shell.dart';
import '../../features/lab/presentation/lab_shell.dart';

// Route name constants.
abstract final class Routes {
  static const login = '/login';
  static const registerPatient = '/register/patient';
  static const registerLab = '/register/lab';
  static const patientShell = '/patient';
  static const labShell = '/lab';
  static const labPending = '/lab-pending';
  static const adminUnsupported = '/admin-unsupported';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _SessionListenable(ref);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionNotifierProvider);
      final status = session.status;
      final user = session.user;
      final isLoggingIn = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.registerPatient ||
          state.matchedLocation == Routes.registerLab;

      // Still loading — stay put (avoid redirect race).
      if (status == SessionStatus.initial || status == SessionStatus.loading) {
        return null;
      }

      if (status == SessionStatus.unauthenticated) {
        return isLoggingIn ? null : Routes.login;
      }

      // Authenticated — route by role.
      if (user != null) {
        switch (user.role) {
          case UserRole.admin:
            return Routes.adminUnsupported;
          case UserRole.labStaff:
            final onboarding = user.labProfile?.onboardingStatus;
            if (onboarding != LabOnboardingStatus.active) {
              return Routes.labPending;
            }
            if (isLoggingIn) return Routes.labShell;
            return null;
          case UserRole.patient:
            if (isLoggingIn) return Routes.patientShell;
            return null;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.registerPatient,
        builder: (_, __) => const RegisterScreen(mode: RegisterMode.patient),
      ),
      GoRoute(
        path: Routes.registerLab,
        builder: (_, __) => const RegisterScreen(mode: RegisterMode.lab),
      ),
      GoRoute(
        path: Routes.labPending,
        builder: (_, __) => const LabPendingScreen(),
      ),
      GoRoute(
        path: Routes.adminUnsupported,
        builder: (_, __) => const AdminUnsupportedScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: Routes.patientShell,
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.patientShell}/bookings',
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.patientShell}/results',
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.patientShell}/trends',
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.patientShell}/profile',
            builder: (_, __) => const _EmptyTab(),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => LabShell(child: child),
        routes: [
          GoRoute(
            path: Routes.labShell,
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.labShell}/analytics',
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.labShell}/reviews',
            builder: (_, __) => const _EmptyTab(),
          ),
          GoRoute(
            path: '${Routes.labShell}/bookings',
            builder: (_, __) => const _EmptyTab(),
          ),
        ],
      ),
    ],
  );
});

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Notifies GoRouter whenever the session state changes.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionNotifierProvider, (_, __) => notifyListeners());
  }
}
