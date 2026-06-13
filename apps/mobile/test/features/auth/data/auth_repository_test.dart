import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/auth/data/auth_models.dart';
import 'package:testly/features/auth/data/auth_repository.dart';

/// Builds a Dio instance whose responses are driven by [handler].
Dio _testDio(
  void Function(RequestOptions options, RequestInterceptorHandler handler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(
    InterceptorsWrapper(onRequest: handler),
  );
  return dio;
}

void main() {
  group('AuthRepository', () {
    // ─── login ──────────────────────────────────────────────────────────────

    group('login', () {
      test('returns LoginResponse on 200', () async {
        final dio = _testDio((options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'access_token': 'acc-tok',
                'refresh_token': 'ref-tok',
                'user': {
                  'id': 'u-1',
                  'email': 'patient@testly.com',
                  'role': 'Patient',
                  'lab_profile': null,
                  'patient_profile': null,
                },
              },
            ),
          );
        });

        final repo = AuthRepository(dio);
        final result = await repo.login(
          email: 'patient@testly.com',
          password: 'password123',
          selectedRole: 'patient',
        );

        expect(result.accessToken, 'acc-tok');
        expect(result.refreshToken, 'ref-tok');
        expect(result.user.email, 'patient@testly.com');
        expect(result.user.role, UserRole.patient);
      });

      test('sends correct body fields', () async {
        RequestOptions? captured;
        final dio = _testDio((options, handler) {
          captured = options;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'access_token': 't',
              'refresh_token': 'r',
              'user': {
                'id': 'u',
                'email': 'e@e.com',
                'role': 'Patient',
                'lab_profile': null,
                'patient_profile': null,
              },
            },
          ));
        });

        await AuthRepository(dio).login(
          email: 'lab@testly.com',
          password: 'pw123',
          selectedRole: 'lab',
        );

        expect((captured!.data as Map)['email'], 'lab@testly.com');
        expect((captured!.data as Map)['selectedRole'], 'lab');
      });

      test('throws ApiException on 401', () async {
        final dio = _testDio((options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                data: {'message': 'Invalid credentials'},
              ),
            ),
          );
        });

        await expectLater(
          AuthRepository(dio).login(
            email: 'bad@bad.com',
            password: 'wrong',
            selectedRole: 'patient',
          ),
          throwsA(isA<ApiException>().having((e) => e.isAuthError, 'isAuthError', true)),
        );
      });
    });

    // ─── getMe ──────────────────────────────────────────────────────────────

    group('getMe', () {
      test('returns AuthUser on 200', () async {
        final dio = _testDio((options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'id': 'u-2',
              'email': 'lab@testly.com',
              'role': 'LabStaff',
              'lab_profile': {
                'id': 'lp-1',
                'lab_name': 'Alborg',
                'onboarding_status': 'Active',
              },
              'patient_profile': null,
            },
          ));
        });

        final user = await AuthRepository(dio).getMe();
        expect(user.role, UserRole.labStaff);
        expect(user.labProfile?.onboardingStatus, LabOnboardingStatus.active);
      });

      test('throws ApiException on network error', () async {
        final dio = _testDio((options, handler) {
          handler.reject(
            DioException(requestOptions: options),
          );
        });

        await expectLater(
          AuthRepository(dio).getMe(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    // ─── logout ─────────────────────────────────────────────────────────────

    group('logout', () {
      test('posts refresh_token when provided', () async {
        RequestOptions? captured;
        final dio = _testDio((options, handler) {
          captured = options;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        });

        await AuthRepository(dio).logout(refreshToken: 'ref-tok');

        expect((captured!.data as Map)['refresh_token'], 'ref-tok');
      });

      test('posts empty body when no refresh_token', () async {
        RequestOptions? captured;
        final dio = _testDio((options, handler) {
          captured = options;
          handler.resolve(Response(requestOptions: options, statusCode: 200));
        });

        await AuthRepository(dio).logout();
        expect((captured!.data as Map).containsKey('refresh_token'), false);
      });
    });

    // ─── registerPatient ────────────────────────────────────────────────────

    group('registerPatient', () {
      test('sends all required fields', () async {
        RequestOptions? captured;
        final dio = _testDio((options, handler) {
          captured = options;
          handler.resolve(Response(requestOptions: options, statusCode: 201));
        });

        await AuthRepository(dio).registerPatient(
          email: 'new@testly.com',
          password: 'password123',
          fullName: 'Mazen Amir',
          phone: '01012345678',
          address: 'Cairo',
        );

        final body = captured!.data as Map;
        expect(body['email'], 'new@testly.com');
        expect(body['full_name'], 'Mazen Amir');
        expect(body['phone'], '01012345678');
        expect(body['address'], 'Cairo');
      });

      test('throws ApiException on 409 conflict', () async {
        final dio = _testDio((options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {'message': 'Email already registered'},
            ),
          ));
        });

        await expectLater(
          AuthRepository(dio).registerPatient(
            email: 'exist@testly.com',
            password: 'pw',
            fullName: 'X',
            phone: '01000000000',
            address: 'Cairo',
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 409)
                .having((e) => e.message, 'message', contains('already')),
          ),
        );
      });
    });
  });
}
