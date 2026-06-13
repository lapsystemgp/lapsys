import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class NotificationRepository {
  const NotificationRepository(this._dio);
  final Dio _dio;

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    try {
      await _dio.post(
        '/notifications/device',
        data: {'fcm_token': fcmToken, 'platform': platform},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> removeDevice(String fcmToken) async {
    try {
      await _dio.delete(
        '/notifications/device',
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.read(dioClientProvider)),
);
