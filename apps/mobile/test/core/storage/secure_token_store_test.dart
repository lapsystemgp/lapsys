import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testly/core/storage/secure_token_store.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late SecureTokenStore store;

  setUp(() {
    storage = MockFlutterSecureStorage();
    store = SecureTokenStore(storage);
  });

  group('SecureTokenStore', () {
    group('getAccessToken', () {
      test('reads from the access_token key', () async {
        when(() => storage.read(key: 'access_token'))
            .thenAnswer((_) async => 'my-access-tok');
        expect(await store.getAccessToken(), 'my-access-tok');
        verify(() => storage.read(key: 'access_token')).called(1);
      });

      test('returns null when no token is stored', () async {
        when(() => storage.read(key: 'access_token'))
            .thenAnswer((_) async => null);
        expect(await store.getAccessToken(), isNull);
      });
    });

    group('getRefreshToken', () {
      test('reads from the refresh_token key', () async {
        when(() => storage.read(key: 'refresh_token'))
            .thenAnswer((_) async => 'my-refresh-tok');
        expect(await store.getRefreshToken(), 'my-refresh-tok');
      });
    });

    group('saveTokens', () {
      test('writes both keys atomically', () async {
        when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        await store.saveTokens(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
        );
        verify(() => storage.write(key: 'access_token', value: 'access-123')).called(1);
        verify(() => storage.write(key: 'refresh_token', value: 'refresh-456')).called(1);
      });
    });

    group('saveAccessToken', () {
      test('overwrites only the access token key', () async {
        when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        await store.saveAccessToken('new-access');
        verify(() => storage.write(key: 'access_token', value: 'new-access')).called(1);
        verifyNever(() => storage.write(key: 'refresh_token', value: any(named: 'value')));
      });
    });

    group('clearTokens', () {
      test('deletes both keys', () async {
        when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
        await store.clearTokens();
        verify(() => storage.delete(key: 'access_token')).called(1);
        verify(() => storage.delete(key: 'refresh_token')).called(1);
      });
    });
  });
}
