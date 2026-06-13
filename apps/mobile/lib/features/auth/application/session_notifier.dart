import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_token_store.dart';
import '../../../core/network/dio_client.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

part 'session_notifier.freezed.dart';

enum SessionStatus { initial, loading, authenticated, unauthenticated, error }

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    @Default(SessionStatus.initial) SessionStatus status,
    AuthUser? user,
    String? error,
  }) = _SessionState;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SecureTokenStore get _tokenStore => ref.read(secureTokenStoreProvider);

  /// Called at app start — reads stored tokens and validates them against /auth/me.
  Future<void> restore() async {
    state = state.copyWith(status: SessionStatus.loading);
    final token = await _tokenStore.getAccessToken();
    if (token == null) {
      state = state.copyWith(status: SessionStatus.unauthenticated);
      return;
    }
    try {
      final user = await _repo.getMe();
      state = state.copyWith(status: SessionStatus.authenticated, user: user);
    } on ApiException {
      await _tokenStore.clearTokens();
      state = state.copyWith(status: SessionStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    state = state.copyWith(status: SessionStatus.loading, error: null);
    try {
      final result = await _repo.login(
        email: email,
        password: password,
        selectedRole: selectedRole,
      );
      await _tokenStore.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      // Hydrate with the full user object from /auth/me for lab_profile.
      final user = await _repo.getMe();
      state = state.copyWith(
        status: SessionStatus.authenticated,
        user: user,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        error: e.message,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    try {
      await _repo.logout(refreshToken: refreshToken);
    } catch (_) {
      // Best-effort — always clear local tokens regardless.
    }
    await _tokenStore.clearTokens();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}

final sessionNotifierProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
