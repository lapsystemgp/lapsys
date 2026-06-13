import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import 'booking_models.dart';

class BookingRepository {
  BookingRepository(this._dio);

  final Dio _dio;

  Future<BookingAvailabilityResponse> getAvailability({
    required String labId,
    required String testId,
    String? dateFrom,
    int? days,
  }) async {
    try {
      final params = <String, dynamic>{
        'labId': labId,
        'testId': testId,
      };
      if (dateFrom != null) params['dateFrom'] = dateFrom;
      if (days != null) params['days'] = days;

      final response = await _dio.get(
        '/bookings/availability',
        queryParameters: params,
      );
      return BookingAvailabilityResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BookingItem> createBooking({
    required String labId,
    required String testId,
    required BookingType bookingType,
    String? slotId,
    String? homeAddress,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      final body = <String, dynamic>{
        'labId': labId,
        'testId': testId,
        'bookingType': bookingType.name == 'labVisit'
            ? 'LabVisit'
            : bookingType.name == 'homeCollection'
                ? 'HomeCollection'
                : 'HomeTestKit',
      };
      if (slotId != null) body['slotId'] = slotId;
      if (homeAddress != null) body['homeAddress'] = homeAddress;
      if (paymentMethod != null) {
        body['paymentMethod'] = _paymentMethodToString(paymentMethod);
      }

      final response = await _dio.post('/bookings', data: body);
      return BookingItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BookingItem> demoPayment(
      String bookingId, String outcome) async {
    try {
      final response = await _dio.post(
        '/bookings/$bookingId/demo-online-payment',
        data: {'outcome': outcome},
      );
      return BookingItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BookingListResponse> getPatientBookings() async {
    try {
      final response = await _dio.get('/bookings/patient');
      return BookingListResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BookingItem> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/bookings/$bookingId/patient-cancel');
      return BookingItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  String _paymentMethodToString(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.cashHomeCollection:
        return 'CashHomeCollection';
      case PaymentMethod.cashLabVisit:
        return 'CashLabVisit';
      case PaymentMethod.cashOnDelivery:
        return 'CashOnDelivery';
    }
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(dioClientProvider)),
);
