import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'selectedRole': selectedRole,
        },
      );
      final data = res.data!;
      // The backend returns: { message, user, access_token, refresh_token }
      // Map snake_case keys to our camelCase freezed model.
      return LoginResponse(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthUser> getMe() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _dio.post<void>(
        '/auth/logout',
        data: refreshToken != null ? {'refresh_token': refreshToken} : {},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    try {
      await _dio.post<void>(
        '/auth/register/patient',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'address': address,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> registerLab({
    required String email,
    required String password,
    required String labName,
    required String address,
    String? phone,
  }) async {
    try {
      await _dio.post<void>(
        '/auth/register/lab',
        data: {
          'email': email,
          'password': password,
          'lab_name': labName,
          'address': address,
          if (phone != null) 'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});
