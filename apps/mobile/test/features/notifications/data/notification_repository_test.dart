import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/notifications/data/notification_repository.dart';

Dio _testDio(
  void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

void main() {
  group('NotificationRepository.registerDevice', () {
    test('sends POST /notifications/device with fcm_token and platform', () async {
      RequestOptions? captured;
      dynamic capturedData;

      final dio = _testDio((opts, handler) {
        captured = opts;
        capturedData = opts.data;
        handler.resolve(Response(requestOptions: opts, statusCode: 204));
      });

      await NotificationRepository(dio).registerDevice(
        fcmToken: 'test-fcm-token-123',
        platform: 'android',
      );

      expect(captured!.path, '/notifications/device');
      expect(captured!.method, 'POST');
      expect((capturedData as Map)['fcm_token'], 'test-fcm-token-123');
      expect((capturedData as Map)['platform'], 'android');
    });

    test('sends correct token for iOS platform', () async {
      dynamic capturedData;
      final dio = _testDio((opts, handler) {
        capturedData = opts.data;
        handler.resolve(Response(requestOptions: opts, statusCode: 204));
      });

      await NotificationRepository(dio).registerDevice(
        fcmToken: 'ios-token-abc',
        platform: 'ios',
      );

      expect((capturedData as Map)['platform'], 'ios');
      expect((capturedData as Map)['fcm_token'], 'ios-token-abc');
    });

    test('completes without throwing on 204', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(requestOptions: opts, statusCode: 204));
      });

      await expectLater(
        NotificationRepository(dio).registerDevice(
          fcmToken: 'any-token',
          platform: 'android',
        ),
        completes,
      );
    });

    test('throws ApiException on 401', () async {
      final dio = _testDio((opts, handler) {
        handler.reject(DioException(
          requestOptions: opts,
          response: Response(
            requestOptions: opts,
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
        ));
      });

      await expectLater(
        NotificationRepository(dio).registerDevice(
          fcmToken: 'tok',
          platform: 'android',
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.isAuthError, 'isAuthError', true)),
      );
    });

    test('throws ApiException on 500', () async {
      final dio = _testDio((opts, handler) {
        handler.reject(DioException(
          requestOptions: opts,
          response: Response(
            requestOptions: opts,
            statusCode: 500,
            data: {'message': 'Internal Server Error'},
          ),
        ));
      });

      await expectLater(
        NotificationRepository(dio).registerDevice(
          fcmToken: 'tok',
          platform: 'ios',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('NotificationRepository.removeDevice', () {
    test('sends DELETE /notifications/device with fcm_token', () async {
      RequestOptions? captured;
      dynamic capturedData;

      final dio = _testDio((opts, handler) {
        captured = opts;
        capturedData = opts.data;
        handler.resolve(Response(requestOptions: opts, statusCode: 204));
      });

      await NotificationRepository(dio).removeDevice('token-to-remove');

      expect(captured!.path, '/notifications/device');
      expect(captured!.method, 'DELETE');
      expect((capturedData as Map)['fcm_token'], 'token-to-remove');
    });

    test('completes without throwing on 204', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(requestOptions: opts, statusCode: 204));
      });

      await expectLater(
        NotificationRepository(dio).removeDevice('any-token'),
        completes,
      );
    });

    test('throws ApiException on 401', () async {
      final dio = _testDio((opts, handler) {
        handler.reject(DioException(
          requestOptions: opts,
          response: Response(
            requestOptions: opts,
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
        ));
      });

      await expectLater(
        NotificationRepository(dio).removeDevice('tok'),
        throwsA(isA<ApiException>()
            .having((e) => e.isAuthError, 'isAuthError', true)),
      );
    });
  });
}
