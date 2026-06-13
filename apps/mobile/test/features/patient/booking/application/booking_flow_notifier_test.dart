import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/features/patient/booking/application/booking_flow_notifier.dart';
import 'package:testly/features/patient/booking/data/booking_models.dart';
import 'package:testly/features/patient/booking/data/booking_repository.dart';

// ─── Mock ─────────────────────────────────────────────────────────────────────

class MockBookingRepository extends Mock implements BookingRepository {}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _labVisitParams = BookingFlowParams(
  labId: 'lab-1',
  testId: 'test-1',
  labName: 'Alborg Lab',
  testName: 'CBC',
  priceEgp: 300,
  supportsHomeCollection: false,
  supportsHomeTestKit: false,
);

const _homeCollectionParams = BookingFlowParams(
  labId: 'lab-2',
  testId: 'test-2',
  labName: 'Cairo Lab',
  testName: 'Lipid Panel',
  priceEgp: 400,
  supportsHomeCollection: true,
  supportsHomeTestKit: false,
);

const _slot = BookingSlot(
  id: 'slot-1',
  startsAt: '2026-06-25T09:00:00Z',
  endsAt: '2026-06-25T09:30:00Z',
);

const _bookingItem = BookingItem(
  id: 'b-1',
  status: BookingStatus.pending,
  bookingType: BookingType.labVisit,
  scheduledAt: '2026-06-25T09:00:00Z',
  totalPriceEgp: 300,
  paymentMethod: PaymentMethod.cashLabVisit,
  paymentStatus: PaymentStatus.pending,
  lab: BookingItemLab(id: 'l-1', name: 'Alborg Lab', address: 'Cairo', homeCollection: false, homeTestKit: false),
  test: BookingItemTest(id: 't-1', name: 'CBC', priceEgp: 300),
  timeline: [],
);

ProviderContainer _makeContainer(MockBookingRepository repo) {
  return ProviderContainer(
    overrides: [bookingRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  late MockBookingRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(BookingType.labVisit);
    registerFallbackValue(PaymentMethod.cashLabVisit);
  });

  setUp(() {
    mockRepo = MockBookingRepository();
  });

  group('BookingFlowNotifier — initial state', () {
    test('starts at type step with correct params', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final state = container.read(bookingFlowProvider(_labVisitParams));

      expect(state.step, BookingStep.type);
      expect(state.params.testName, 'CBC');
      expect(state.selectedType, isNull);
      expect(state.slots, isEmpty);
    });
  });

  group('selectType', () {
    test('transitions to slot step and loads availability', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(
            items: [_slot],
          ));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container
          .read(bookingFlowProvider(_labVisitParams).notifier)
          .selectType(BookingType.labVisit);

      final state = container.read(bookingFlowProvider(_labVisitParams));
      expect(state.step, BookingStep.slot);
      expect(state.selectedType, BookingType.labVisit);
      expect(state.slotsLoading, false);
      expect(state.slots, hasLength(1));
      expect(state.slots.first.id, 'slot-1');
    });

    test('fetches availability using params from arg', () async {
      String? capturedLabId, capturedTestId;

      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((inv) async {
        capturedLabId = inv.namedArguments[#labId] as String?;
        capturedTestId = inv.namedArguments[#testId] as String?;
        return const BookingAvailabilityResponse(items: []);
      });

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container
          .read(bookingFlowProvider(_labVisitParams).notifier)
          .selectType(BookingType.labVisit);

      expect(capturedLabId, 'lab-1');
      expect(capturedTestId, 'test-1');
    });
  });

  group('selectSlot', () {
    test('LabVisit goes to payment after slot selection', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(items: [_slot]));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final notifier = container.read(bookingFlowProvider(_labVisitParams).notifier);
      await notifier.selectType(BookingType.labVisit);
      notifier.selectSlot(_slot);

      expect(container.read(bookingFlowProvider(_labVisitParams)).step,
          BookingStep.payment);
      expect(container.read(bookingFlowProvider(_labVisitParams)).selectedSlot,
          _slot);
    });

    test('HomeCollection goes to address step after slot selection', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(items: [_slot]));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final notifier =
          container.read(bookingFlowProvider(_homeCollectionParams).notifier);
      await notifier.selectType(BookingType.homeCollection);
      notifier.selectSlot(_slot);

      expect(
        container.read(bookingFlowProvider(_homeCollectionParams)).step,
        BookingStep.address,
      );
    });
  });

  group('submitAddress → selectPayment → confirm', () {
    test('full cash-payment happy path reaches done step', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(items: [_slot]));

      when(() => mockRepo.createBooking(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            bookingType: any(named: 'bookingType'),
            slotId: any(named: 'slotId'),
            homeAddress: any(named: 'homeAddress'),
            paymentMethod: any(named: 'paymentMethod'),
          )).thenAnswer((_) async => _bookingItem);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final notifier = container.read(bookingFlowProvider(_labVisitParams).notifier);
      await notifier.selectType(BookingType.labVisit);
      notifier.selectSlot(_slot);
      notifier.selectPayment(PaymentMethod.cashLabVisit);
      await notifier.confirm();

      final state = container.read(bookingFlowProvider(_labVisitParams));
      expect(state.step, BookingStep.done);
      expect(state.result?.id, 'b-1');
    });

    test('online payment also calls demoPayment', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(items: []));

      when(() => mockRepo.createBooking(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            bookingType: any(named: 'bookingType'),
            slotId: any(named: 'slotId'),
            homeAddress: any(named: 'homeAddress'),
            paymentMethod: any(named: 'paymentMethod'),
          )).thenAnswer((_) async => _bookingItem);

      when(() => mockRepo.demoPayment(any(), any()))
          .thenAnswer((_) async => _bookingItem.copyWith(
              paymentStatus: PaymentStatus.paid));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final notifier = container.read(bookingFlowProvider(_labVisitParams).notifier);
      await notifier.selectType(BookingType.labVisit);
      notifier.skipSlot();
      notifier.selectPayment(PaymentMethod.online);
      await notifier.confirm();

      verify(() => mockRepo.demoPayment('b-1', 'success')).called(1);
      final state = container.read(bookingFlowProvider(_labVisitParams));
      expect(state.step, BookingStep.done);
      expect(state.result?.paymentStatus, PaymentStatus.paid);
    });
  });

  group('back()', () {
    test('back() from slot step returns to type step', () async {
      when(() => mockRepo.getAvailability(
            labId: any(named: 'labId'),
            testId: any(named: 'testId'),
            days: any(named: 'days'),
          )).thenAnswer((_) async => const BookingAvailabilityResponse(items: []));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final notifier = container.read(bookingFlowProvider(_labVisitParams).notifier);
      await notifier.selectType(BookingType.labVisit);
      expect(container.read(bookingFlowProvider(_labVisitParams)).step,
          BookingStep.slot);

      notifier.back();
      expect(container.read(bookingFlowProvider(_labVisitParams)).step,
          BookingStep.type);
    });
  });
}
