import 'package:dio/dio.dart';
import '../storage/secure_token_store.dart';

/// Attaches the Bearer token to every request and silently rotates it on 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.tokenStore, required this.dio});

  final SecureTokenStore tokenStore;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStore.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Attempt one silent refresh.
    final refreshToken = await tokenStore.getRefreshToken();
    if (refreshToken == null) {
      await tokenStore.clearTokens();
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final res = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = res.data!;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;
      await tokenStore.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Retry the original request with the new token.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      await tokenStore.clearTokens();
      handler.next(e);
    }
  }
}
