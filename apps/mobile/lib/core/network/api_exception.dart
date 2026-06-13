import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.isAuthError = false,
  });

  final String message;
  final int statusCode;
  final bool isAuthError;

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException fromDioException(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : e.message ?? 'Network error';
    return ApiException(
      message: message,
      statusCode: statusCode,
      isAuthError: statusCode == 401,
    );
  }
}
