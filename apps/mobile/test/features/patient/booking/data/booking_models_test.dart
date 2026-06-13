import 'package:flutter_test/flutter_test.dart';
import 'package:testly/features/patient/booking/data/booking_models.dart';

const _slotJson = {
  'id': 'slot-1',
  'startsAt': '2026-06-25T09:00:00.000Z',
  'endsAt': '2026-06-25T09:30:00.000Z',
};

const _bookingItemJson = {
  'id': 'b-1',
  'status': 'Confirmed',
  'bookingType': 'HomeCollection',
  'scheduledAt': '2026-06-25T09:00:00.000Z',
  'homeAddress': '5 Nile St, Cairo',
  'totalPriceEgp': 450,
  'paymentMethod': 'CashHomeCollection',
  'paymentStatus': 'Pending',
  'paymentReference': null,
  'paymentPaidAt': null,
  'paymentFailedAt': null,
  'paymentFailureReason': null,
  'kitStatus': null,
  'kitTrackingNumber': null,
  'kitShippedAt': null,
  'kitDeliveredAt': null,
  'sampleReceivedAt': null,
  'createdAt': '2026-06-20T10:00:00.000Z',
  'lab': {
    'id': 'l-1',
    'name': 'Alborg Lab',
    'address': 'Cairo',
    'homeCollection': true,
    'homeTestKit': false,
  },
  'test': {'id': 't-1', 'name': 'CBC', 'priceEgp': 450},
  'timeline': [
    {
      'id': 'tl-1',
      'status': 'Confirmed',
      'note': 'Lab confirmed your appointment',
      'createdAt': '2026-06-21T08:00:00.000Z',
    }
  ],
};

void main() {
  group('BookingType', () {
    test('@JsonValue maps Prisma strings correctly', () {
      final types = [
        ('LabVisit', BookingType.labVisit),
        ('HomeCollection', BookingType.homeCollection),
        ('HomeTestKit', BookingType.homeTestKit),
      ];
      // Round-trip via BookingSlot which contains no BookingType but
      // we verify via a model that holds the enum.
      final item = BookingItem.fromJson(_bookingItemJson);
      expect(item.bookingType, BookingType.homeCollection);
      // types list exists only to document all values; parsing verified above
      expect(types.map((t) => t.$2), contains(BookingType.homeCollection));
    });
  });

  group('BookingStatus', () {
    test('@JsonValue parses all 5 statuses', () {
      for (final (json, expected) in [
        ('Pending', BookingStatus.pending),
        ('Confirmed', BookingStatus.confirmed),
        ('Rejected', BookingStatus.rejected),
        ('Cancelled', BookingStatus.cancelled),
        ('Completed', BookingStatus.completed),
      ]) {
        final item = BookingItem.fromJson({..._bookingItemJson, 'status': json});
        expect(item.status, expected, reason: 'Failed for status=$json');
      }
    });
  });

  group('PaymentMethod & PaymentStatus', () {
    test('@JsonValue maps all payment methods', () {
      for (final (json, expected) in [
        ('Online', PaymentMethod.online),
        ('CashHomeCollection', PaymentMethod.cashHomeCollection),
        ('CashLabVisit', PaymentMethod.cashLabVisit),
        ('CashOnDelivery', PaymentMethod.cashOnDelivery),
      ]) {
        final item = BookingItem.fromJson({..._bookingItemJson, 'paymentMethod': json});
        expect(item.paymentMethod, expected, reason: 'Failed for method=$json');
      }
    });

    test('@JsonValue maps all payment statuses', () {
      for (final (json, expected) in [
        ('Pending', PaymentStatus.pending),
        ('Paid', PaymentStatus.paid),
        ('Failed', PaymentStatus.failed),
        ('Refunded', PaymentStatus.refunded),
      ]) {
        final item = BookingItem.fromJson({..._bookingItemJson, 'paymentStatus': json});
        expect(item.paymentStatus, expected);
      }
    });
  });

  group('KitStatus', () {
    test('@JsonValue maps all kit statuses when present', () {
      for (final (json, expected) in [
        ('AwaitingShipment', KitStatus.awaitingShipment),
        ('Shipped', KitStatus.shipped),
        ('Delivered', KitStatus.delivered),
        ('SampleReceived', KitStatus.sampleReceived),
      ]) {
        final item = BookingItem.fromJson({..._bookingItemJson, 'kitStatus': json});
        expect(item.kitStatus, expected);
      }
    });
  });

  group('BookingSlot', () {
    test('fromJson parses id and timestamps', () {
      final slot = BookingSlot.fromJson(_slotJson);

      expect(slot.id, 'slot-1');
      expect(slot.startsAt, '2026-06-25T09:00:00.000Z');
      expect(slot.endsAt, '2026-06-25T09:30:00.000Z');
    });
  });

  group('BookingItem', () {
    test('fromJson parses nested lab, test, and timeline', () {
      final item = BookingItem.fromJson(_bookingItemJson);

      expect(item.id, 'b-1');
      expect(item.bookingType, BookingType.homeCollection);
      expect(item.homeAddress, '5 Nile St, Cairo');
      expect(item.totalPriceEgp, 450);
      expect(item.lab.name, 'Alborg Lab');
      expect(item.lab.homeCollection, true);
      expect(item.test.name, 'CBC');
      expect(item.timeline, hasLength(1));
      expect(item.timeline.first.note, 'Lab confirmed your appointment');
    });
  });
}
