import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/patient/workspace/data/patient_repository.dart';
import 'package:testly/features/patient/trends/data/health_profile_models.dart';

Dio _testDio(
  void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

final _profileJson = {
  'range': '12m',
  'groupBy': 'analyte',
  'series': [
    {
      'canonicalCode': 'GLU',
      'displayName': 'Glucose',
      'chartUnit': 'mmol/L',
      'category': 'Metabolic',
      'labTestName': null,
      'trend': {
        'direction': 'stable',
        'narrative': 'Values are similar.',
        'qualitativeNote': null,
      },
      'points': [
        {
          'testDate': '2026-01-10T00:00:00.000Z',
          'value': 5.0,
          'comparable': true,
          'comparabilityNote': null,
          'bookingId': 'b-1',
          'labName': 'MedLab',
          'labTestName': 'GTT',
          'refLow': 3.9,
          'refHigh': 6.1,
          'abnormal': false,
        }
      ],
    }
  ],
  'labTestGroups': <Map<String, dynamic>>[],
  'pdfOnlyBookings': <Map<String, dynamic>>[],
  'hasStructuredData': true,
  'disclaimer': 'Not medical advice.',
};

void main() {
  group('PatientRepository.getHealthProfile', () {
    test('returns HealthProfileResponse on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      final result = await PatientRepository(dio).getHealthProfile();

      expect(result.range, '12m');
      expect(result.groupBy, 'analyte');
      expect(result.hasStructuredData, true);
      expect(result.series, hasLength(1));
      expect(result.series.first.displayName, 'Glucose');
      expect(result.disclaimer, 'Not medical advice.');
    });

    test('sends range and groupBy as query parameters', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      await PatientRepository(dio).getHealthProfile(range: '3m', groupBy: 'lab_test');

      expect(captured!.queryParameters['range'], '3m');
      expect(captured!.queryParameters['groupBy'], 'lab_test');
    });

    test('uses default params when not specified', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      await PatientRepository(dio).getHealthProfile();

      expect(captured!.queryParameters['range'], '12m');
      expect(captured!.queryParameters['groupBy'], 'analyte');
    });

    test('hits the correct endpoint', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      await PatientRepository(dio).getHealthProfile();

      expect(captured!.path, '/patient/health-profile');
      expect(captured!.method, 'GET');
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
        PatientRepository(dio).getHealthProfile(),
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
        PatientRepository(dio).getHealthProfile(),
        throwsA(isA<ApiException>()),
      );
    });

    test('parses series points with abnormal flag', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      final result = await PatientRepository(dio).getHealthProfile();
      final point = result.series.first.points.first;

      expect(point.value, 5.0);
      expect(point.refLow, 3.9);
      expect(point.refHigh, 6.1);
      expect(point.abnormal, false);
    });

    test('parses trend direction correctly', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      final result = await PatientRepository(dio).getHealthProfile();
      final trend = result.series.first.trend;

      expect(trend.direction, 'stable');
      expect(trend.narrative, isNotEmpty);
      expect(trend.qualitativeNote, isNull);
    });

    test('returns isA<HealthProfileResponse>', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _profileJson,
        ));
      });

      final result = await PatientRepository(dio).getHealthProfile();

      expect(result, isA<HealthProfileResponse>());
    });
  });
}
