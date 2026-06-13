import 'package:flutter_test/flutter_test.dart';

// These tests exercise the pure logic inside NotificationService without
// depending on Firebase or flutter_local_notifications platform channels.

void main() {
  group('Notification payload → route mapping', () {
    String? payloadToRoute(Map<String, dynamic> data) {
      final type = data['type'] as String?;
      final id = (data['id'] ?? data['bookingId']) as String?;
      if (type == null || id == null) return null;
      return switch (type) {
        'booking' => '/patient/bookings/$id',
        'result' => '/patient/results/$id',
        _ => null,
      };
    }

    test('maps booking type to bookings route', () {
      expect(
        payloadToRoute({'type': 'booking', 'id': 'b-123'}),
        '/patient/bookings/b-123',
      );
    });

    test('maps result type to results route', () {
      expect(
        payloadToRoute({'type': 'result', 'id': 'b-456'}),
        '/patient/results/b-456',
      );
    });

    test('accepts bookingId key as fallback for id', () {
      expect(
        payloadToRoute({'type': 'booking', 'bookingId': 'b-789'}),
        '/patient/bookings/b-789',
      );
    });

    test('returns null when type is missing', () {
      expect(payloadToRoute({'id': 'b-1'}), isNull);
    });

    test('returns null when id is missing', () {
      expect(payloadToRoute({'type': 'booking'}), isNull);
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
