import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/patient_repository.dart';
import '../data/workspace_models.dart';

// Single source of truth for the patient workspace.
// Invalidate this provider to trigger a full refresh.
final workspaceProvider =
    FutureProvider<PatientWorkspaceResponse>((ref) async {
  return ref.watch(patientRepositoryProvider).getWorkspace();
});

// Derived selectors so individual tabs only rebuild when their slice changes.
final upcomingBookingsProvider = Provider<AsyncValue<List<WorkspaceBooking>>>(
  (ref) => ref.watch(workspaceProvider).whenData((w) => w.bookings.upcoming),
);

final pastBookingsProvider = Provider<AsyncValue<List<WorkspaceBooking>>>(
  (ref) => ref.watch(workspaceProvider).whenData((w) => w.bookings.past),
);

final resultsProvider = Provider<AsyncValue<List<WorkspaceResult>>>(
  (ref) => ref.watch(workspaceProvider).whenData((w) => w.results),
);

final workspaceProfileProvider = Provider<AsyncValue<WorkspaceProfile>>(
  (ref) => ref.watch(workspaceProvider).whenData((w) => w.profile),
);
