import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import 'lab_models.dart';

class PublicRepository {
  PublicRepository(this._dio);

  final Dio _dio;

  Future<PublicLabListResponse> getLabs(LabsFilter filter) async {
    try {
      final params = <String, dynamic>{
        'page': filter.page,
        'pageSize': 10,
      };
      if (filter.q != null) params['q'] = filter.q;
      if (filter.city != null) params['city'] = filter.city;
      if (filter.sort != null) params['sort'] = filter.sort;
      if (filter.maxPriceEgp != null) params['maxPriceEgp'] = filter.maxPriceEgp;
      if (filter.homeCollectionOnly) params['homeCollection'] = true;
      if (filter.userLat != null) params['userLat'] = filter.userLat;
      if (filter.userLng != null) params['userLng'] = filter.userLng;

      final response = await _dio.get('/public/labs', queryParameters: params);
      return PublicLabListResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Searches medical tests (e.g. "cbc"), grouped by name + category.
  /// Mirrors the frontend "Tests" tab — `GET /public/tests`.
  Future<PublicTestListResponse> getTests({String? q, int page = 1}) async {
    try {
      final params = <String, dynamic>{'page': page, 'pageSize': 50};
      if (q != null && q.isNotEmpty) params['q'] = q;

      final response = await _dio.get('/public/tests', queryParameters: params);
      return PublicTestListResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Returns every lab that offers a specific test, plus their coordinates so
  /// the client can rank them by distance — `GET /public/tests/by-name`.
  Future<TestOffersResponse> getTestOffers({
    required String name,
    String? category,
  }) async {
    try {
      final params = <String, dynamic>{'name': name};
      if (category != null && category.isNotEmpty) params['category'] = category;

      final response =
          await _dio.get('/public/tests/by-name', queryParameters: params);
      return TestOffersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PublicLabDetailResponse> getLabDetail(
    String labId, {
    String? q,
    String? category,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'pageSize': 20};
      if (q != null) params['q'] = q;
      if (category != null) params['category'] = category;

      final response = await _dio.get(
        '/public/labs/$labId',
        queryParameters: params,
      );
      return PublicLabDetailResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final publicRepositoryProvider = Provider<PublicRepository>(
  (ref) => PublicRepository(ref.watch(dioClientProvider)),
);

final labsListProvider =
    FutureProvider.family<PublicLabListResponse, LabsFilter>((ref, filter) {
  return ref.watch(publicRepositoryProvider).getLabs(filter);
});

final labDetailProvider =
    FutureProvider.family<PublicLabDetailResponse, String>((ref, labId) {
  return ref.watch(publicRepositoryProvider).getLabDetail(labId);
});

/// Test search results keyed by the raw query string ('' = all tests).
final testsListProvider =
    FutureProvider.family<PublicTestListResponse, String>((ref, q) {
  return ref.watch(publicRepositoryProvider).getTests(q: q.isEmpty ? null : q);
});

/// Identifies a test by its (name, category) pair — the key for its offers.
typedef TestKey = ({String name, String category});

/// All labs offering a given test. Keyed by (name, category).
final testOffersProvider =
    FutureProvider.family<TestOffersResponse, TestKey>((ref, key) {
  return ref
      .watch(publicRepositoryProvider)
      .getTestOffers(name: key.name, category: key.category);
});
