import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../trends/data/health_profile_models.dart';
import 'workspace_models.dart';

class PatientRepository {
  PatientRepository(this._dio);

  final Dio _dio;

  Future<PatientWorkspaceResponse> getWorkspace() async {
    try {
      final response = await _dio.get('/patient/workspace');
      return PatientWorkspaceResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WorkspaceProfile> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    LabHistorySharing? labHistorySharing,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      if (labHistorySharing != null) {
        body['labHistorySharing'] = labHistorySharing == LabHistorySharing.sameLabOnly
            ? 'SAME_LAB_ONLY'
            : 'FULL_HISTORY_AUTHORIZED';
      }

      final response = await _dio.patch('/patient/profile', data: body);
      return WorkspaceProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dio.post('/patient/reviews', data: {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<HealthProfileResponse> getHealthProfile({
    String range = '12m',
    String groupBy = 'analyte',
  }) async {
    try {
      final response = await _dio.get(
        '/patient/health-profile',
        queryParameters: {'range': range, 'groupBy': groupBy},
      );
      return HealthProfileResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepository(ref.watch(dioClientProvider)),
);
