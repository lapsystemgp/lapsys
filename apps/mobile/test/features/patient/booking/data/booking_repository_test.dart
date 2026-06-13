import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/patient/booking/data/booking_models.dart';
import 'package:testly/features/patient/booking/data/booking_repository.dart';

Dio _testDio(
  void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

const _bookingItemJson = {
  'id': 'b-1',
  'status': 'Pending',
  'bookingType': 'LabVisit',
  'scheduledAt': '2026-06-25T09:00:00.000Z',
  'homeAddress': null,
  'totalPriceEgp': 300,
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
  'createdAt': '2026-06-20T10:00:00.000Z',
  'lab': {
    'id': 'l-1',
    'name': 'Alborg Lab',
    'address': 'Cairo',
    'homeCollection': false,
    'homeTestKit': false,
  },
  'test': {'id': 't-1', 'name': 'CBC', 'priceEgp': 300},
  'timeline': [],
};

void main() {
  group('BookingRepository.getAvailability', () {
    test('returns BookingAvailabilityResponse on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: {
            'items': [
              {
                'id': 'slot-1',
                'startsAt': '2026-06-25T09:00:00.000Z',
                'endsAt': '2026-06-25T09:30:00.000Z',
              }
            ]
          },
        ));
      });

      final result = await BookingRepository(dio).getAvailability(
        labId: 'lab-1',
        testId: 'test-1',
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 'slot-1');
    });

    test('sends labId and testId as query parameters', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: {'items': []},
        ));
      });

      await BookingRepository(dio).getAvailability(
        labId: 'lab-99',
        testId: 'test-77',
        days: 7,
      );

      expect(captured!.queryParameters['labId'], 'lab-99');
      expect(captured!.queryParameters['testId'], 'test-77');
      expect(captured!.queryParameters['days'], 7);
    });
  });

  group('BookingRepository.createBooking', () {
    test('returns BookingItem on 201 and sends required fields', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
          Response(requestOptions: opts, statusCode: 201, data: _bookingItemJson),
        );
      });

      final result = await BookingRepository(dio).createBooking(
        labId: 'lab-1',
        testId: 'test-1',
        bookingType: BookingType.labVisit,
        paymentMethod: PaymentMethod.cashLabVisit,
      );

      expect(result.id, 'b-1');
      expect(result.bookingType, BookingType.labVisit);

      final body = captured!.data as Map;
      expect(body['labId'], 'lab-1');
      expect(body['testId'], 'test-1');
      expect(body['bookingType'], 'LabVisit');
      expect(body['paymentMethod'], 'CashLabVisit');
    });

    test('sends HomeCollection and homeAddress when provided', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
          Response(requestOptions: opts, statusCode: 201, data: _bookingItemJson),
        );
      });

      await BookingRepository(dio).createBooking(
        labId: 'lab-1',
        testId: 'test-1',
        bookingType: BookingType.homeCollection,
        homeAddress: '5 Nile St, Cairo',
        paymentMethod: PaymentMethod.cashHomeCollection,
      );

      final body = captured!.data as Map;
      expect(body['bookingType'], 'HomeCollection');
      expect(body['homeAddress'], '5 Nile St, Cairo');
      expect(body['paymentMethod'], 'CashHomeCollection');
    });

    test('sends slotId when provided', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
          Response(requestOptions: opts, statusCode: 201, data: _bookingItemJson),
        );
      });

      await BookingRepository(dio).createBooking(
        labId: 'lab-1',
        testId: 'test-1',
        bookingType: BookingType.labVisit,
        slotId: 'slot-42',
      );

      expect((captured!.data as Map)['slotId'], 'slot-42');
    });

    test('throws ApiException on 400', () async {
      final dio = _testDio((opts, handler) {
        handler.reject(DioException(
          requestOptions: opts,
          response: Response(
            requestOptions: opts,
            statusCode: 400,
            data: {'message': 'Slot already taken'},
          ),
        ));
      });

      await expectLater(
        BookingRepository(dio).createBooking(
          labId: 'l',
          testId: 't',
          bookingType: BookingType.labVisit,
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', contains('Slot'))),
      );
    });
  });

  group('BookingRepository.demoPayment', () {
    test('sends outcome in body and returns BookingItem', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
          Response(requestOptions: opts, statusCode: 200, data: _bookingItemJson),
        );
      });

      final result = await BookingRepository(dio).demoPayment('b-1', 'success');

      expect(result.id, 'b-1');
      expect((captured!.data as Map)['outcome'], 'success');
      expect(captured!.path, contains('b-1'));
    });
  });

  group('BookingRepository.cancelBooking', () {
    test('sends PATCH to the correct path', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
          Response(requestOptions: opts, statusCode: 200, data: _bookingItemJson),
        );
      });

      await BookingRepository(dio).cancelBooking('b-99');

      expect(captured!.method, 'PATCH');
      expect(captured!.path, contains('b-99'));
      expect(captured!.path, contains('patient-cancel'));
    });
  });
}
