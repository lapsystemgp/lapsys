import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lab_repository.dart';
import '../data/lab_workspace_models.dart';

final labWorkspaceProvider = FutureProvider<LabWorkspaceResponse>((ref) {
  return ref.watch(labRepositoryProvider).getWorkspace();
});

final labInfoProvider = Provider<AsyncValue<LabInfo>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData((w) => w.lab);
});

final labBookingsProvider = Provider<AsyncValue<List<LabBookingItem>>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData((w) => w.bookings);
});

final pendingBookingsProvider = Provider<AsyncValue<List<LabBookingItem>>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData(
        (w) => w.bookings
            .where((b) => b.status.name == 'pending')
            .toList(),
      );
});

final confirmedBookingsProvider =
    Provider<AsyncValue<List<LabBookingItem>>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData(
        (w) => w.bookings
            .where((b) => b.status.name == 'confirmed')
            .toList(),
      );
});

final labTestsProvider = Provider<AsyncValue<List<LabTest>>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData((w) => w.tests);
});

final labScheduleProvider = Provider<AsyncValue<List<LabScheduleSlot>>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData((w) => w.schedule);
});

final labAnalyticsProvider = Provider<AsyncValue<LabAnalytics>>((ref) {
  return ref.watch(labWorkspaceProvider).whenData((w) => w.analytics);
});
