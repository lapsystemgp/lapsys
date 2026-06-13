import 'package:flutter_test/flutter_test.dart';
import 'package:testly/features/patient/workspace/data/workspace_models.dart';
import 'package:testly/features/patient/booking/data/booking_models.dart';

const _bookingJson = {
  'id': 'b-1',
  'status': 'Confirmed',
  'bookingType': 'LabVisit',
  'scheduledAt': '2026-06-25T09:00:00.000Z',
  'totalPriceEgp': 300,
  'homeAddress': null,
  'paymentMethod': 'CashLabVisit',
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
  'lab': {'id': 'l-1', 'name': 'Alborg Lab', 'address': 'Cairo'},
  'test': {'id': 't-1', 'name': 'CBC', 'priceEgp': 300},
  'timeline': [
    {'id': 'tl-1', 'status': 'Confirmed', 'note': null, 'createdAt': '2026-06-24T10:00:00.000Z'},
  ],
};

const _resultPendingJson = {
  'bookingId': 'b-2',
  'bookingStatus': 'Completed',
  'scheduledAt': '2026-05-10T09:00:00.000Z',
  'labName': 'Alborg Lab',
  'testName': 'Lipid Panel',
  'resultStatus': 'Pending',
  'hasStructuredData': false,
  'structuredObservationCount': 0,
  'file': null,
  'summary': null,
  'review': null,
  'canReview': false,
};

const _resultDeliveredJson = {
  'bookingId': 'b-3',
  'bookingStatus': 'Completed',
  'scheduledAt': '2026-04-01T09:00:00.000Z',
  'labName': 'Alborg Lab',
  'testName': 'CBC',
  'resultStatus': 'Delivered',
  'hasStructuredData': true,
  'structuredObservationCount': 12,
  'file': {
    'id': 'f-1',
    'fileName': 'result_cbc.pdf',
    'fileUrl': 'https://example.com/result_cbc.pdf',
    'mimeType': 'application/pdf',
    'sizeBytes': 102400,
    'uploadedAt': '2026-04-02T10:00:00.000Z',
  },
  'summary': {
    'summary': 'All values within normal range.',
    'highlights': {
      'items': [
        {'key': 'wbc', 'label': 'WBC', 'value': '7.2 × 10⁹/L', 'kind': 'key_value'},
      ],
    },
  },
  'review': {
    'id': 'rv-1',
    'rating': 5,
    'comment': 'Quick results!',
    'status': 'Published',
    'createdAt': '2026-04-03T09:00:00.000Z',
  },
  'canReview': false,
};

void main() {
  group('ResultStatus', () {
    test('@JsonValue parses all three statuses', () {
      for (final (json, expected) in [
        ('Pending', ResultStatus.pending),
        ('Uploaded', ResultStatus.uploaded),
        ('Delivered', ResultStatus.delivered),
      ]) {
        final r = WorkspaceResult.fromJson({..._resultPendingJson, 'resultStatus': json});
        expect(r.resultStatus, expected, reason: 'Failed for $json');
      }
    });
  });

  group('LabHistorySharing', () {
    test('@JsonValue maps both sharing modes', () {
      final same = WorkspaceProfile.fromJson({
        'fullName': 'Test',
        'phone': '01012345678',
        'address': 'Cairo',
        'email': 'test@test.com',
        'labHistorySharing': 'SAME_LAB_ONLY',
      });
      final full = WorkspaceProfile.fromJson({
        'fullName': 'Test',
        'phone': '01012345678',
        'address': 'Cairo',
        'email': 'test@test.com',
        'labHistorySharing': 'FULL_HISTORY_AUTHORIZED',
      });

      expect(same.labHistorySharing, LabHistorySharing.sameLabOnly);
      expect(full.labHistorySharing, LabHistorySharing.fullHistoryAuthorized);
    });
  });

  group('WorkspaceBooking', () {
    test('fromJson parses booking with all nested objects', () {
      final b = WorkspaceBooking.fromJson(_bookingJson);

      expect(b.id, 'b-1');
      expect(b.status, BookingStatus.confirmed);
      expect(b.bookingType, BookingType.labVisit);
      expect(b.totalPriceEgp, 300);
      expect(b.paymentMethod, PaymentMethod.cashLabVisit);
      expect(b.paymentStatus, PaymentStatus.pending);
      expect(b.kitStatus, isNull);
      expect(b.lab.name, 'Alborg Lab');
      expect(b.test.name, 'CBC');
      expect(b.timeline, hasLength(1));
      expect(b.timeline.first.status, 'Confirmed');
    });

    test('fromJson handles HomeTestKit with kit tracking fields', () {
      final b = WorkspaceBooking.fromJson({
        ..._bookingJson,
        'bookingType': 'HomeTestKit',
        'kitStatus': 'Shipped',
        'kitTrackingNumber': 'EG123456',
        'kitShippedAt': '2026-06-22T08:00:00.000Z',
      });

      expect(b.bookingType, BookingType.homeTestKit);
      expect(b.kitStatus, KitStatus.shipped);
      expect(b.kitTrackingNumber, 'EG123456');
    });
  });

  group('WorkspaceResult', () {
    test('fromJson parses pending result (no file, no summary)', () {
      final r = WorkspaceResult.fromJson(_resultPendingJson);

      expect(r.bookingId, 'b-2');
      expect(r.resultStatus, ResultStatus.pending);
      expect(r.hasStructuredData, false);
      expect(r.file, isNull);
      expect(r.summary, isNull);
      expect(r.review, isNull);
      expect(r.canReview, false);
    });

    test('fromJson parses delivered result with file, summary, and review', () {
      final r = WorkspaceResult.fromJson(_resultDeliveredJson);

      expect(r.resultStatus, ResultStatus.delivered);
      expect(r.hasStructuredData, true);
      expect(r.structuredObservationCount, 12);

      // File
      expect(r.file?.fileName, 'result_cbc.pdf');
      expect(r.file?.sizeBytes, 102400);

      // Summary
      expect(r.summary?.summary, 'All values within normal range.');
      expect(r.summary?.highlights.items, hasLength(1));
      expect(r.summary?.highlights.items.first.key, 'wbc');

      // Review
      expect(r.review?.rating, 5);
      expect(r.review?.status, ReviewStatus.published);
    });
  });

  group('PatientWorkspaceResponse', () {
    test('fromJson parses profile, bookings, and results together', () {
      final workspace = PatientWorkspaceResponse.fromJson({
        'profile': {
          'fullName': 'Mazen Amir',
          'phone': '01012345678',
          'address': '5 Tahrir Square, Cairo',
          'email': 'patient@testly.com',
          'labHistorySharing': 'FULL_HISTORY_AUTHORIZED',
        },
        'bookings': {
          'upcoming': [_bookingJson],
          'past': [],
        },
        'results': [_resultPendingJson, _resultDeliveredJson],
      });

      expect(workspace.profile.fullName, 'Mazen Amir');
      expect(workspace.profile.labHistorySharing,
          LabHistorySharing.fullHistoryAuthorized);
      expect(workspace.bookings.upcoming, hasLength(1));
      expect(workspace.bookings.past, isEmpty);
      expect(workspace.results, hasLength(2));
    });
  });
}
