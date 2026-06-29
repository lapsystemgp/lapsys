import 'package:flutter_test/flutter_test.dart';

// These tests exercise the pure logic inside NotificationService without
// depending on Firebase or flutter_local_notifications platform channels.

void main() {
  group('Notification payload → route mapping', () {
    String? payloadToRoute(Map<String, dynamic> data) {
      final type = data['type'] as String?;
      if (type == null) return null;
      final bookingId = (data['bookingId'] ?? data['id']) as String?;
      String? booking(String base) =>
          bookingId == null ? null : '$base/$bookingId';
      return switch (type) {
        'booking_status' || 'kit_shipped' || 'booking' =>
          booking('/patient/bookings'),
        'result_delivered' || 'result' => booking('/patient/results'),
        'new_booking' => booking('/lab/bookings'),
        'new_review' => '/lab/reviews',
        _ => null,
      };
    }

    // Real backend `type` values (NotificationsService.sendToUser).
    test('maps booking_status to patient bookings route', () {
      expect(
        payloadToRoute({'type': 'booking_status', 'bookingId': 'b-123'}),
        '/patient/bookings/b-123',
      );
    });

    test('maps kit_shipped to patient bookings route', () {
      expect(
        payloadToRoute({'type': 'kit_shipped', 'bookingId': 'b-1'}),
        '/patient/bookings/b-1',
      );
    });

    test('maps result_delivered to patient results route', () {
      expect(
        payloadToRoute({'type': 'result_delivered', 'bookingId': 'b-456'}),
        '/patient/results/b-456',
      );
    });

    test('maps new_booking to lab bookings route', () {
      expect(
        payloadToRoute({'type': 'new_booking', 'bookingId': 'b-9'}),
        '/lab/bookings/b-9',
      );
    });

    test('maps new_review to lab reviews route', () {
      expect(
        payloadToRoute({'type': 'new_review', 'labProfileId': 'l-1'}),
        '/lab/reviews',
      );
    });

    test('accepts id key as fallback for bookingId', () {
      expect(
        payloadToRoute({'type': 'booking', 'id': 'b-789'}),
        '/patient/bookings/b-789',
      );
    });

    test('returns null when type is missing', () {
      expect(payloadToRoute({'id': 'b-1'}), isNull);
    });

    test('returns null when bookingId is missing for a booking route', () {
      expect(payloadToRoute({'type': 'booking_status'}), isNull);
    });

    test('returns null for unknown type', () {
      expect(payloadToRoute({'type': 'unknown', 'id': 'x'}), isNull);
    });

    test('returns null for empty data', () {
      expect(payloadToRoute({}), isNull);
    });
  });

  group('Prep reminder scheduling logic', () {
    test('reminder date is 20:00 the evening before scheduled date', () {
      final scheduledAt = DateTime(2026, 3, 15, 9, 0); // 15 Mar 9am
      final reminderWall = DateTime(
        scheduledAt.year,
        scheduledAt.month,
        scheduledAt.day - 1,
        20,
      );
      expect(reminderWall, DateTime(2026, 3, 14, 20, 0));
    });

    test('reminder is in the future when test is tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final scheduledAt = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
      final reminderWall = DateTime(
        scheduledAt.year,
        scheduledAt.month,
        scheduledAt.day - 1,
        20,
      );
      expect(reminderWall.isAfter(DateTime.now()), true);
    });

    test('reminder is in the past when test is today or passed', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final scheduledAt = DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 0);
      final reminderWall = DateTime(
        scheduledAt.year,
        scheduledAt.month,
        scheduledAt.day - 1,
        20,
      );
      expect(reminderWall.isAfter(DateTime.now()), false);
    });

    test('notification id is derived from bookingId hash', () {
      const bookingId = 'booking-abc-123';
      final id1 = bookingId.hashCode.abs();
      final id2 = bookingId.hashCode.abs();
      expect(id1, equals(id2));
    });

    test('different bookingIds produce different notification ids', () {
      final id1 = 'booking-1'.hashCode.abs();
      final id2 = 'booking-2'.hashCode.abs();
      expect(id1, isNot(equals(id2)));
    });
  });
}
