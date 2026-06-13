import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/patient/workspace/data/patient_repository.dart';
import 'package:testly/features/patient/workspace/data/workspace_models.dart';

Dio _testDio(
  void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

const _workspaceJson = {
  'profile': {
    'fullName': 'Mazen Amir',
    'phone': '01012345678',
    'address': '5 Tahrir Square, Cairo',
    'email': 'patient@testly.com',
    'labHistorySharing': 'SAME_LAB_ONLY',
  },
  'bookings': {'upcoming': [], 'past': []},
  'results': [],
};

const _profileJson = {
  'fullName': 'Updated Name',
  'phone': '01098765432',
  'address': 'Alex',
  'email': 'patient@testly.com',
  'labHistorySharing': 'FULL_HISTORY_AUTHORIZED',
};

void main() {
  group('PatientRepository.getWorkspace', () {
    test('returns PatientWorkspaceResponse on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _workspaceJson,
        ));
      });

      final result = await PatientRepository(dio).getWorkspace();

      expect(result.profile.fullName, 'Mazen Amir');
      expect(result.profile.email, 'patient@testly.com');
      expect(result.bookings.upcoming, isEmpty);
      expect(result.results, isEmpty);
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
        PatientRepository(dio).getWorkspace(),
        throwsA(isA<ApiException>().having((e) => e.isAuthError, 'isAuthError', true)),
      );
    });
  });

  group('PatientRepository.updateProfile', () {
    test('sends only provided fields (no extras when fields are null)', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: _profileJson));
      });

      await PatientRepository(dio).updateProfile(fullName: 'New Name');

      final body = captured!.data as Map;
      expect(body.containsKey('fullName'), true);
      expect(body['fullName'], 'New Name');
      expect(body.containsKey('phone'), false);
      expect(body.containsKey('address'), false);
    });

    test('converts LabHistorySharing enum to correct string', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: _profileJson));
      });

      await PatientRepository(dio).updateProfile(
        labHistorySharing: LabHistorySharing.fullHistoryAuthorized,
      );

      expect(
        (captured!.data as Map)['labHistorySharing'],
        'FULL_HISTORY_AUTHORIZED',
      );
    });

    test('returns WorkspaceProfile on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: _profileJson));
      });

      final result = await PatientRepository(dio).updateProfile(fullName: 'Updated Name');

      expect(result.fullName, 'Updated Name');
      expect(result.labHistorySharing, LabHistorySharing.fullHistoryAuthorized);
    });
  });

  group('PatientRepository.submitReview', () {
    test('sends bookingId, rating, and comment in body', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(requestOptions: opts, statusCode: 201, data: {}));
      });

      await PatientRepository(dio).submitReview(
        bookingId: 'b-1',
        rating: 4,
        comment: 'Good service',
      );

      final body = captured!.data as Map;
      expect(body['bookingId'], 'b-1');
      expect(body['rating'], 4);
      expect(body['comment'], 'Good service');
    });

    test('omits comment key when comment is null', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(requestOptions: opts, statusCode: 201, data: {}));
      });

      await PatientRepository(dio).submitReview(
        bookingId: 'b-2',
        rating: 5,
        comment: null,
      );

      expect((captured!.data as Map).containsKey('comment'), false);
    });
  });
}
