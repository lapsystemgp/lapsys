import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/features/patient/booking/data/booking_models.dart';
import 'package:testly/features/patient/workspace/application/workspace_provider.dart';
import 'package:testly/features/patient/workspace/data/patient_repository.dart';
import 'package:testly/features/patient/workspace/data/workspace_models.dart';

// ─── Mock ─────────────────────────────────────────────────────────────────────

class MockPatientRepository extends Mock implements PatientRepository {}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _upcomingBooking = WorkspaceBooking(
  id: 'b-upcoming',
  status: BookingStatus.confirmed,
  bookingType: BookingType.labVisit,
  scheduledAt: '2026-06-30T10:00:00Z',
  totalPriceEgp: 200,
  paymentMethod: PaymentMethod.cashLabVisit,
  paymentStatus: PaymentStatus.pending,
  lab: const WorkspaceBookingLab(id: 'l-1', name: 'Lab A', address: 'Cairo'),
  test: const WorkspaceBookingTest(id: 't-1', name: 'CBC', priceEgp: 200),
  timeline: const [],
);

final _pastBooking = WorkspaceBooking(
  id: 'b-past',
  status: BookingStatus.completed,
  bookingType: BookingType.labVisit,
  scheduledAt: '2026-05-01T10:00:00Z',
  totalPriceEgp: 300,
  paymentMethod: PaymentMethod.cashLabVisit,
  paymentStatus: PaymentStatus.paid,
  lab: const WorkspaceBookingLab(id: 'l-2', name: 'Lab B', address: 'Alex'),
  test: const WorkspaceBookingTest(id: 't-2', name: 'Lipid Panel', priceEgp: 300),
  timeline: const [],
);

final _result = WorkspaceResult(
  bookingId: 'b-past',
  bookingStatus: BookingStatus.completed,
  scheduledAt: '2026-05-01T10:00:00Z',
  labName: 'Lab B',
  testName: 'Lipid Panel',
  resultStatus: ResultStatus.delivered,
  hasStructuredData: false,
  structuredObservationCount: 0,
  canReview: true,
);

const _profile = WorkspaceProfile(
  fullName: 'Ali Hassan',
  phone: '01023456789',
  address: '10 Nile St',
  email: 'ali@example.com',
  labHistorySharing: LabHistorySharing.sameLabOnly,
);

PatientWorkspaceResponse _makeWorkspace({
  List<WorkspaceBooking> upcoming = const [],
  List<WorkspaceBooking> past = const [],
  List<WorkspaceResult> results = const [],
  WorkspaceProfile profile = _profile,
}) =>
    PatientWorkspaceResponse(
      profile: profile,
      bookings: WorkspaceBookings(upcoming: upcoming, past: past),
      results: results,
    );

ProviderContainer _makeContainer(MockPatientRepository repo) {
  return ProviderContainer(
    overrides: [patientRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  late MockPatientRepository mockRepo;

  setUp(() {
    mockRepo = MockPatientRepository();
  });

  group('workspaceProvider', () {
    test('returns PatientWorkspaceResponse from repository', () async {
      final workspace = _makeWorkspace(
        upcoming: [_upcomingBooking],
        past: [_pastBooking],
        results: [_result],
      );
      when(() => mockRepo.getWorkspace()).thenAnswer((_) async => workspace);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final result = await container.read(workspaceProvider.future);

      expect(result.profile.fullName, 'Ali Hassan');
      expect(result.bookings.upcoming, hasLength(1));
      expect(result.bookings.past, hasLength(1));
      expect(result.results, hasLength(1));
    });

    test('exposes error state on repository failure', () async {
      when(() => mockRepo.getWorkspace()).thenThrow(Exception('Network error'));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final async = container.read(workspaceProvider);
      // Wait for the future to settle
      await Future<void>.delayed(Duration.zero);
      final settled = container.read(workspaceProvider);

      expect(settled.hasError, true);
    });
  });

  group('upcomingBookingsProvider', () {
    test('returns only upcoming bookings from workspace', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer((_) async => _makeWorkspace(
            upcoming: [_upcomingBooking],
          ));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final upcoming = container.read(upcomingBookingsProvider);

      expect(upcoming.value, hasLength(1));
      expect(upcoming.value!.first.id, 'b-upcoming');
      expect(upcoming.value!.first.status, BookingStatus.confirmed);
    });

    test('returns empty list when no upcoming bookings', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer(
        (_) async => _makeWorkspace(past: [_pastBooking]),
      );

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final upcoming = container.read(upcomingBookingsProvider);

      expect(upcoming.value, isEmpty);
    });
  });

  group('pastBookingsProvider', () {
    test('returns only past bookings from workspace', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer((_) async => _makeWorkspace(
            past: [_pastBooking],
          ));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final past = container.read(pastBookingsProvider);

      expect(past.value, hasLength(1));
      expect(past.value!.first.id, 'b-past');
      expect(past.value!.first.status, BookingStatus.completed);
    });
  });

  group('resultsProvider', () {
    test('returns results from workspace', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer((_) async => _makeWorkspace(
            results: [_result],
          ));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final results = container.read(resultsProvider);

      expect(results.value, hasLength(1));
      expect(results.value!.first.bookingId, 'b-past');
      expect(results.value!.first.resultStatus, ResultStatus.delivered);
    });

    test('returns empty list when workspace has no results', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer(
        (_) async => _makeWorkspace(),
      );

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final results = container.read(resultsProvider);

      expect(results.value, isEmpty);
    });
  });

  group('workspaceProfileProvider', () {
    test('returns profile from workspace', () async {
      when(() => mockRepo.getWorkspace()).thenAnswer(
        (_) async => _makeWorkspace(),
      );

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(workspaceProvider.future);
      final profile = container.read(workspaceProfileProvider);

      expect(profile.value?.fullName, 'Ali Hassan');
      expect(profile.value?.labHistorySharing, LabHistorySharing.sameLabOnly);
    });
  });
}
