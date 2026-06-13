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

      final response = await _dio.get('/public/labs', queryParameters: params);
      return PublicLabListResponse.fromJson(
          response.data as Map<String, dynamic>);
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
