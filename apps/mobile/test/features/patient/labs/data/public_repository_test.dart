import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/features/patient/labs/data/lab_models.dart';
import 'package:testly/features/patient/labs/data/public_repository.dart';

Dio _testDio(
  void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

const _labCardJson = {
  'id': 'lab-1',
  'name': 'Alborg Laboratories',
  'address': 'Cairo',
  'city': 'Cairo',
  'phone': null,
  'contactEmail': null,
  'accreditation': 'CAP',
  'turnaroundTime': null,
  'homeCollection': true,
  'homeTestKit': false,
  'rating': 4.5,
  'reviews': 50,
  'distanceKm': null,
  'testsAvailable': 30,
  'startingFromEgp': 150,
  'priceForQueryEgp': null,
  'imageEmoji': '🔬',
};

const _listResponseJson = {
  'items': [_labCardJson],
  'pagination': {'page': 1, 'pageSize': 10, 'totalCount': 1},
};

void main() {
  group('PublicRepository.getLabs', () {
    test('returns PublicLabListResponse on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _listResponseJson,
        ));
      });

      final result = await PublicRepository(dio).getLabs(const LabsFilter());

      expect(result.items, hasLength(1));
      expect(result.items.first.name, 'Alborg Laboratories');
      expect(result.pagination.totalCount, 1);
    });

    test('sends page and pageSize in query params', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: _listResponseJson,
        ));
      });

      await PublicRepository(dio).getLabs(const LabsFilter(page: 3));

      expect(captured!.queryParameters['page'], 3);
      expect(captured!.queryParameters['pageSize'], 10);
    });

    test('sends q param when filter has a query string', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: _listResponseJson));
      });

      await PublicRepository(dio).getLabs(const LabsFilter(q: 'blood'));

      expect(captured!.queryParameters['q'], 'blood');
    });

    test('sends homeCollection=true when homeCollectionOnly filter is set', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: _listResponseJson));
      });

      await PublicRepository(dio)
          .getLabs(const LabsFilter(homeCollectionOnly: true));

      expect(captured!.queryParameters['homeCollection'], true);
    });

    test('throws ApiException on server error', () async {
      final dio = _testDio((opts, handler) {
        handler.reject(DioException(
          requestOptions: opts,
          response: Response(
            requestOptions: opts,
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
        ));
      });

      await expectLater(
        PublicRepository(dio).getLabs(const LabsFilter()),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });

  group('PublicRepository.getLabDetail', () {
    final detailJson = {
      'lab': _labCardJson,
      'tests': [
        {
          'id': 'lt-1',
          'name': 'CBC',
          'category': 'Haematology',
          'priceEgp': 300,
          'description': null,
          'preparation': null,
          'turnaroundTime': null,
          'parametersCount': null,
        }
      ],
      'pagination': {'page': 1, 'pageSize': 20, 'totalCount': 1},
      'reviewItems': [],
    };

    test('returns PublicLabDetailResponse on 200', () async {
      final dio = _testDio((opts, handler) {
        handler.resolve(Response(
          requestOptions: opts,
          statusCode: 200,
          data: detailJson,
        ));
      });

      final result = await PublicRepository(dio).getLabDetail('lab-1');

      expect(result.lab.id, 'lab-1');
      expect(result.tests, hasLength(1));
      expect(result.reviewItems, isEmpty);
    });

    test('sends labId in the URL path', () async {
      RequestOptions? captured;
      final dio = _testDio((opts, handler) {
        captured = opts;
        handler.resolve(
            Response(requestOptions: opts, statusCode: 200, data: detailJson));
      });

      await PublicRepository(dio).getLabDetail('lab-42');

      expect(captured!.path, contains('lab-42'));
    });
  });
}
