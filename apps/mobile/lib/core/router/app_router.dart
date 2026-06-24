import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/session_notifier.dart';
import '../../features/auth/data/auth_models.dart';
import '../../features/notifications/application/notification_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/lab_pending_screen.dart';
import '../../features/auth/presentation/admin_unsupported_screen.dart';
import '../../features/patient/presentation/patient_shell.dart';
import '../../features/patient/home/presentation/home_screen.dart';
import '../../features/patient/labs/presentation/labs_screen.dart';
import '../../features/patient/labs/presentation/lab_detail_screen.dart';
import '../../features/patient/labs/presentation/test_detail_screen.dart';
import '../../features/patient/booking/data/booking_models.dart';
import '../../features/patient/booking/presentation/booking_flow_screen.dart';
import '../../features/patient/bookings/presentation/my_bookings_screen.dart';
import '../../features/patient/bookings/presentation/booking_detail_screen.dart';
import '../../features/patient/results/presentation/results_screen.dart';
import '../../features/patient/results/presentation/result_detail_screen.dart';
import '../../features/patient/profile/presentation/profile_screen.dart';
import '../../features/patient/trends/presentation/trends_screen.dart';
import '../../features/patient/assistant/presentation/assistant_screen.dart';
import '../../features/patient/workspace/data/workspace_models.dart';
import '../../features/lab/presentation/lab_shell.dart';
import '../../features/lab/presentation/dashboard_screen.dart';
import '../../features/lab/presentation/lab_bookings_screen.dart';
import '../../features/lab/presentation/lab_booking_detail_screen.dart';
import '../../features/lab/presentation/analytics_screen.dart';
import '../../features/lab/presentation/reviews_screen.dart';
import '../../features/lab/presentation/lab_profile_screen.dart';
import '../../features/lab/data/lab_workspace_models.dart';

abstract final class Routes {
  static const login = '/login';
  static const registerPatient = '/register/patient';
  static const registerLab = '/register/lab';
  static const patientShell = '/patient';
  static const bookingFlow = '/patient/book';
  static const labShell = '/lab';
  static const labPending = '/lab-pending';
  static const adminUnsupported = '/admin-unsupported';
  static const assistant = '/patient/assistant';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterListenable(ref);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Consume a pending deep-link from a notification tap (terminated-state cold start).
      final pendingRoute = ref.read(pendingNotificationRouteProvider);
      if (pendingRoute != null) {
        ref.read(pendingNotificationRouteProvider.notifier).state = null;
        // Only deep-link if the user is authenticated.
        final sessionStatus = ref.read(sessionNotifierProvider).status;
        if (sessionStatus == SessionStatus.authenticated) {
          return pendingRoute;
        }
      }

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

      // AI Health Assistant — full-screen, outside the shell.
      GoRoute(
        path: Routes.assistant,
        builder: (_, __) => const AssistantScreen(),
      ),

      // ─── Patient shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => PatientShell(child: child),
        routes: [
          // Home tab — landing screen (root of the shell)
          GoRoute(
            path: Routes.patientShell,
            builder: (_, __) => const HomeScreen(),
            routes: [
              // Search screen — Tests/Labs tabs, opened from the home screen.
              GoRoute(
                path: 'search',
                builder: (_, state) {
                  final q = state.uri.queryParameters['q'];
                  final sort = state.uri.queryParameters['sort'];
                  // Test-name searches open the Tests tab; a "browse by" sort
                  // opens the Labs tab.
                  final tabIndex =
                      (q != null && q.isNotEmpty) ? 0 : (sort != null ? 1 : 0);
                  return LabsScreen(
                    initialQuery: q,
                    initialSort: sort,
                    initialTabIndex: tabIndex,
                  );
                },
              ),
              GoRoute(
                path: 'labs/:labId',
                builder: (_, state) => LabDetailScreen(
                    labId: state.pathParameters['labId']!),
              ),
              GoRoute(
                path: 'tests/:testName',
                builder: (_, state) => TestDetailScreen(
                  testName: Uri.decodeComponent(
                      state.pathParameters['testName']!),
                  category: state.uri.queryParameters['category'] ?? '',
                ),
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
            builder: (_, __) => const TrendsScreen(),
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
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/lab/analytics',
            builder: (_, __) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/lab/reviews',
            builder: (_, __) => const ReviewsScreen(),
          ),
          GoRoute(
            path: '/lab/bookings',
            builder: (_, __) => const LabBookingsScreen(),
            routes: [
              GoRoute(
                path: ':bookingId',
                builder: (_, state) => LabBookingDetailScreen(
                  bookingId: state.pathParameters['bookingId']!,
                  initial: state.extra as LabBookingItem?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/lab/profile',
            builder: (_, __) => const LabProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// Fires the router refresh on both session changes and incoming notification
// deep links so the redirect logic can consume pendingNotificationRouteProvider.
class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    ref.listen(sessionNotifierProvider, (_, __) => notifyListeners());
    ref.listen(pendingNotificationRouteProvider, (_, __) => notifyListeners());
  }
}
