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
import '../../features/patient/labs/presentation/labs_screen.dart';
import '../../features/patient/labs/presentation/lab_detail_screen.dart';
import '../../features/patient/booking/data/booking_models.dart';
import '../../features/patient/booking/presentation/booking_flow_screen.dart';
import '../../features/patient/bookings/presentation/my_bookings_screen.dart';
import '../../features/patient/bookings/presentation/booking_detail_screen.dart';
import '../../features/patient/results/presentation/results_screen.dart';
import '../../features/patient/results/presentation/result_detail_screen.dart';
import '../../features/patient/profile/presentation/profile_screen.dart';
import '../../features/patient/workspace/data/workspace_models.dart';
import '../../features/lab/presentation/lab_shell.dart';

abstract final class Routes {
  static const login = '/login';
  static const registerPatient = '/register/patient';
  static const registerLab = '/register/lab';
  static const patientShell = '/patient';
  static const bookingFlow = '/patient/book';
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
      final loc = state.matchedLocation;
      final isLoggingIn = loc == Routes.login ||
          loc == Routes.registerPatient ||
          loc == Routes.registerLab;

      if (status == SessionStatus.initial || status == SessionStatus.loading) {
        return null;
      }

      if (status == SessionStatus.unauthenticated) {
        return isLoggingIn ? null : Routes.login;
      }

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
      GoRoute(path: Routes.labPending, builder: (_, __) => const LabPendingScreen()),
      GoRoute(
        path: Routes.adminUnsupported,
        builder: (_, __) => const AdminUnsupportedScreen(),
      ),

      // Booking flow — full-screen, outside the shell.
      GoRoute(
        path: Routes.bookingFlow,
        builder: (_, state) {
          return BookingFlowScreen(params: state.extra as BookingFlowParams);
        },
      ),

      // ─── Patient shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => PatientShell(child: child),
        routes: [
          // Labs tab — root of the shell
          GoRoute(
            path: Routes.patientShell,
            builder: (_, __) => const LabsScreen(),
            routes: [
              GoRoute(
                path: 'labs/:labId',
                builder: (_, state) => LabDetailScreen(
                    labId: state.pathParameters['labId']!),
              ),
            ],
          ),
          // Bookings tab
          GoRoute(
            path: '/patient/bookings',
            builder: (_, __) => const MyBookingsScreen(),
            routes: [
              GoRoute(
                path: ':bookingId',
                builder: (_, state) => BookingDetailScreen(
                  bookingId: state.pathParameters['bookingId']!,
                  initial: state.extra as WorkspaceBooking?,
                ),
              ),
            ],
          ),
          // Results tab
          GoRoute(
            path: '/patient/results',
            builder: (_, __) => const ResultsScreen(),
            routes: [
              GoRoute(
                path: ':bookingId',
                builder: (_, state) => ResultDetailScreen(
                  bookingId: state.pathParameters['bookingId']!,
                  initial: state.extra as WorkspaceResult?,
                ),
              ),
            ],
          ),
          // Trends tab (Phase 4)
          GoRoute(
            path: '/patient/trends',
            builder: (_, __) =>
                const _ComingSoonScreen(title: 'Health Trends'),
          ),
          // Profile tab
          GoRoute(
            path: '/patient/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ─── Lab shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => LabShell(child: child),
        routes: [
          GoRoute(
            path: Routes.labShell,
            builder: (_, __) => const _ComingSoonScreen(title: 'Dashboard'),
          ),
          GoRoute(
            path: '/lab/analytics',
            builder: (_, __) => const _ComingSoonScreen(title: 'Analytics'),
          ),
          GoRoute(
            path: '/lab/reviews',
            builder: (_, __) => const _ComingSoonScreen(title: 'Reviews'),
          ),
          GoRoute(
            path: '/lab/bookings',
            builder: (_, __) => const _ComingSoonScreen(title: 'Bookings'),
          ),
        ],
      ),
    ],
  );
});

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: 16),
            Text('$title — coming in a future phase',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionNotifierProvider, (_, __) => notifyListeners());
  }
}
