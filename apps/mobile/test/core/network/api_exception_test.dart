import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    group('constructor', () {
      test('holds statusCode, message, and isAuthError', () {
        const ex = ApiException(
          message: 'Not found',
          statusCode: 404,
          isAuthError: false,
        );
        expect(ex.statusCode, 404);
        expect(ex.message, 'Not found');
        expect(ex.isAuthError, false);
      });

      test('isAuthError defaults to false', () {
        const ex = ApiException(message: 'err', statusCode: 500);
        expect(ex.isAuthError, false);
      });
    });

    group('fromDioException', () {
      RequestOptions _opts() => RequestOptions(path: '/test');

      test('extracts message from response data map', () {
        final dio = DioException(
          requestOptions: _opts(),
          response: Response(
            requestOptions: _opts(),
            statusCode: 422,
            data: {'message': 'Validation failed'},
          ),
        );
        final ex = ApiException.fromDioException(dio);
        expect(ex.message, 'Validation failed');
        expect(ex.statusCode, 422);
        expect(ex.isAuthError, false);
      });

      test('sets isAuthError = true when status is 401', () {
        final dio = DioException(
          requestOptions: _opts(),
          response: Response(
            requestOptions: _opts(),
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
        );
        final ex = ApiException.fromDioException(dio);
        expect(ex.isAuthError, true);
        expect(ex.statusCode, 401);
      });

      test('falls back to DioException.message when response data is not a map', () {
        final dio = DioException(
          requestOptions: _opts(),
          message: 'Connection refused',
          response: Response(
            requestOptions: _opts(),
            statusCode: 503,
            data: 'plain string',
          ),
        );
        final ex = ApiException.fromDioException(dio);
        expect(ex.message, 'Connection refused');
      });

      test('uses "Network error" when no response and no message', () {
        final dio = DioException(requestOptions: _opts());
        final ex = ApiException.fromDioException(dio);
        expect(ex.message, 'Network error');
        expect(ex.statusCode, 0);
      });

      test('toString includes status and message', () {
        const ex = ApiException(message: 'Oops', statusCode: 500);
        expect(ex.toString(), contains('500'));
        expect(ex.toString(), contains('Oops'));
      });
    });
  });
}
