import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/core/network/api_exception.dart';
import 'package:testly/core/network/dio_client.dart';
import 'package:testly/features/auth/application/session_notifier.dart';
import 'package:testly/features/auth/data/auth_models.dart';
import 'package:testly/features/auth/data/auth_repository.dart';
import 'package:testly/core/storage/secure_token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _activeLabUser = AuthUser(
  id: 'u-lab',
  email: 'alborglaboratories@testly.com',
  role: UserRole.labStaff,
  labProfile: LabProfile(
    id: 'lp-1',
    labName: 'Alborg',
    onboardingStatus: LabOnboardingStatus.active,
  ),
);

const _patientUser = AuthUser(
  id: 'u-patient',
  email: 'patient@testly.com',
  role: UserRole.patient,
);

const _loginResult = LoginResponse(
  accessToken: 'acc-tok',
  refreshToken: 'ref-tok',
  user: _patientUser,
);

ProviderContainer _makeContainer(
  MockAuthRepository repo,
  MockFlutterSecureStorage rawStorage,
) {
  final tokenStore = SecureTokenStore(rawStorage);
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      secureTokenStoreProvider.overrideWithValue(tokenStore),
    ],
  );
}

void main() {
  late MockAuthRepository mockRepo;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockFlutterSecureStorage();
    registerFallbackValue(const AuthUser(id: '', email: '', role: UserRole.patient));
  });

  // ─── restore ─────────────────────────────────────────────────────────────

  group('restore', () {
    test('sets status to unauthenticated when no stored token', () async {
      when(() => mockStorage.read(key: 'access_token')).thenAnswer((_) async => null);

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).restore();

      expect(
        container.read(sessionNotifierProvider).status,
        SessionStatus.unauthenticated,
      );
    });

    test('sets authenticated + user when stored token is valid', () async {
      when(() => mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-tok');
      when(() => mockRepo.getMe()).thenAnswer((_) async => _patientUser);

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).restore();

      final state = container.read(sessionNotifierProvider);
      expect(state.status, SessionStatus.authenticated);
      expect(state.user?.email, 'patient@testly.com');
    });

    test('clears tokens and sets unauthenticated when /auth/me fails', () async {
      when(() => mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'expired-tok');
      when(() => mockRepo.getMe())
          .thenThrow(const ApiException(message: 'Unauthorized', statusCode: 401, isAuthError: true));
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).restore();

      expect(
        container.read(sessionNotifierProvider).status,
        SessionStatus.unauthenticated,
      );
      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });
  });

  // ─── login ────────────────────────────────────────────────────────────────

  group('login', () {
    test('saves tokens and sets authenticated state on success', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            selectedRole: any(named: 'selectedRole'),
          )).thenAnswer((_) async => _loginResult);
      when(() => mockRepo.getMe()).thenAnswer((_) async => _patientUser);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).login(
            email: 'patient@testly.com',
            password: 'password123',
            selectedRole: 'patient',
          );

      final state = container.read(sessionNotifierProvider);
      expect(state.status, SessionStatus.authenticated);
      expect(state.user?.role, UserRole.patient);
      verify(() => mockStorage.write(key: 'access_token', value: 'acc-tok')).called(1);
      verify(() => mockStorage.write(key: 'refresh_token', value: 'ref-tok')).called(1);
    });

    test('hydrates user from /auth/me after login to get full lab profile', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            selectedRole: any(named: 'selectedRole'),
          )).thenAnswer((_) async => const LoginResponse(
            accessToken: 'a',
            refreshToken: 'r',
            user: AuthUser(id: 'u-lab', email: 'lab@t.com', role: UserRole.labStaff),
          ));
      when(() => mockRepo.getMe()).thenAnswer((_) async => _activeLabUser);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).login(
            email: 'alborglaboratories@testly.com',
            password: 'password123',
            selectedRole: 'lab',
          );

      final state = container.read(sessionNotifierProvider);
      expect(state.user?.labProfile?.onboardingStatus, LabOnboardingStatus.active);
    });

    test('sets unauthenticated with error message on bad credentials', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            selectedRole: any(named: 'selectedRole'),
          )).thenThrow(
        const ApiException(message: 'Invalid credentials', statusCode: 401, isAuthError: true),
      );

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await expectLater(
        container.read(sessionNotifierProvider.notifier).login(
              email: 'bad@bad.com',
              password: 'wrong',
              selectedRole: 'patient',
            ),
        throwsA(isA<ApiException>()),
      );

      final state = container.read(sessionNotifierProvider);
      expect(state.status, SessionStatus.unauthenticated);
      expect(state.error, 'Invalid credentials');
    });
  });

  // ─── logout ───────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears tokens and sets unauthenticated', () async {
      when(() => mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'ref-tok');
      when(() => mockRepo.logout(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async {});
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).logout();

      final state = container.read(sessionNotifierProvider);
      expect(state.status, SessionStatus.unauthenticated);
      expect(state.user, isNull);
      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });

    test('still clears local tokens even when the API call fails', () async {
      when(() => mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'ref-tok');
      when(() => mockRepo.logout(refreshToken: any(named: 'refreshToken')))
          .thenThrow(const ApiException(message: 'Network error', statusCode: 0));
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo, mockStorage);
      addTearDown(container.dispose);

      await container.read(sessionNotifierProvider.notifier).logout();

      // Token wipe happens regardless of API failure.
      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
      expect(
        container.read(sessionNotifierProvider).status,
        SessionStatus.unauthenticated,
      );
    });
  });
}
