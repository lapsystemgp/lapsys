import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    this.isAuthError = false,
    this.isOffline = false,
  });

  final String message;
  final int statusCode;
  final bool isAuthError;
  final bool isOffline;

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException fromDioException(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;

    final isOffline = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;

    if (isOffline) {
      return ApiException(
        message: 'No internet connection. Please check your connection and try again.',
        statusCode: statusCode,
        isOffline: true,
      );
    }

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
