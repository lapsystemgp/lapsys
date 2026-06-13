import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../patient/booking/data/booking_models.dart';
import 'lab_workspace_models.dart';

class LabRepository {
  LabRepository(this._dio);

  final Dio _dio;

  Future<LabWorkspaceResponse> getWorkspace() async {
    try {
      final response = await _dio.get('/lab/workspace');
      return LabWorkspaceResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabInfo> updateProfile({bool? homeTestKit, bool? homeCollection}) async {
    try {
      final body = <String, dynamic>{};
      if (homeTestKit != null) body['homeTestKit'] = homeTestKit;
      if (homeCollection != null) body['homeCollection'] = homeCollection;
      final response = await _dio.patch('/lab/profile', data: body);
      return LabInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabTest> createTest({
    required String name,
    required String category,
    required int priceEgp,
    String? description,
    String? preparation,
    String? turnaroundTime,
    int? parametersCount,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'category': category,
        'priceEgp': priceEgp,
      };
      if (description != null) body['description'] = description;
      if (preparation != null) body['preparation'] = preparation;
      if (turnaroundTime != null) body['turnaroundTime'] = turnaroundTime;
      if (parametersCount != null) body['parametersCount'] = parametersCount;
      if (isActive != null) body['isActive'] = isActive;
      final response = await _dio.post('/lab/tests', data: body);
      return LabTest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabTest> updateTest(
    String testId, {
    String? name,
    String? category,
    int? priceEgp,
    String? description,
    String? preparation,
    String? turnaroundTime,
    int? parametersCount,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (category != null) body['category'] = category;
      if (priceEgp != null) body['priceEgp'] = priceEgp;
      if (description != null) body['description'] = description;
      if (preparation != null) body['preparation'] = preparation;
      if (turnaroundTime != null) body['turnaroundTime'] = turnaroundTime;
      if (parametersCount != null) body['parametersCount'] = parametersCount;
      if (isActive != null) body['isActive'] = isActive;
      final response = await _dio.patch('/lab/tests/$testId', data: body);
      return LabTest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _dio.delete('/lab/tests/$testId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabScheduleSlot> createScheduleSlot({
    required String startsAt,
    required String endsAt,
    int? capacity,
  }) async {
    try {
      final body = <String, dynamic>{'startsAt': startsAt, 'endsAt': endsAt};
      if (capacity != null) body['capacity'] = capacity;
      final response = await _dio.post('/lab/schedule', data: body);
      return LabScheduleSlot.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabScheduleSlot> updateScheduleSlot(
    String slotId, {
    String? startsAt,
    String? endsAt,
    int? capacity,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (startsAt != null) body['startsAt'] = startsAt;
      if (endsAt != null) body['endsAt'] = endsAt;
      if (capacity != null) body['capacity'] = capacity;
      if (isActive != null) body['isActive'] = isActive;
      final response = await _dio.patch('/lab/schedule/$slotId', data: body);
      return LabScheduleSlot.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deactivateScheduleSlot(String slotId) async {
    try {
      await _dio.delete('/lab/schedule/$slotId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabBookingItem> setBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      final statusStr = status == BookingStatus.confirmed ? 'Confirmed' : 'Rejected';
      final response = await _dio.patch(
        '/bookings/$bookingId/lab-status',
        data: {'status': statusStr},
      );
      return LabBookingItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LabBookingItem> updateKitStatus(
    String bookingId,
    KitStatus kitStatus, {
    String? trackingNumber,
  }) async {
    try {
      final body = <String, dynamic>{'kitStatus': _kitStatusString(kitStatus)};
      if (trackingNumber != null) body['trackingNumber'] = trackingNumber;
      final response = await _dio.patch(
        '/bookings/$bookingId/kit-status',
        data: body,
      );
      return LabBookingItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> setResultStatus(
      String bookingId, String status) async {
    try {
      final response = await _dio.patch(
        '/lab/results/$bookingId/status',
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  String _kitStatusString(KitStatus s) {
    switch (s) {
      case KitStatus.awaitingShipment:
        return 'AwaitingShipment';
      case KitStatus.shipped:
        return 'Shipped';
      case KitStatus.delivered:
        return 'Delivered';
      case KitStatus.sampleReceived:
        return 'SampleReceived';
    }
  }
}

final labRepositoryProvider = Provider<LabRepository>(
  (ref) => LabRepository(ref.watch(dioClientProvider)),
);
