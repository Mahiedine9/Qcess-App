import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/features/auth/data/models/auth_response.dart';
import 'package:mobile/features/auth/data/repositories/auth_api_service.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';

import 'auth_repositories_test.mocks.dart';

@GenerateMocks([AuthApiService, TokenStorageService])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApiService mockApiService;
  late MockTokenStorageService mockTokenStorage;

  setUp(() {
    mockApiService = MockAuthApiService();
    mockTokenStorage = MockTokenStorageService();
    repository = AuthRepositoryImpl(
      apiService: mockApiService,
      tokenStorage: mockTokenStorage,
    );
  });

  group('AuthRepositoryImpl', () {
    const testToken = 'test_token_123';
    const testUsername = 'test@ex.com';
    const testAccessCode = '12345';

    final testAuthResponse = AuthResponse(
      token: testToken,
      email: testUsername,
      role: 'USER',
      organisationId: 1,
    );

    group('login', () {
      test('returns token and saves it when login succeeds', () async {
        when(mockApiService.login(any)).thenAnswer((_) async => testAuthResponse);
        when(mockTokenStorage.saveToken(testToken)).thenAnswer((_) async => {});

        final result = await repository.login(testUsername, testAccessCode);

        expect(result, testToken);
        verify(mockApiService.login(any)).called(1);
        verify(mockTokenStorage.saveToken(testToken)).called(1);
      });

      test('throws exception when login fails', () async {
        when(mockApiService.login(any)).thenThrow(Exception('Login failed'));

        expect(
          () => repository.login(testUsername, testAccessCode),
          throwsException,
        );
        verifyNever(mockTokenStorage.saveToken(any));
      });
    });

    group('logout', () {
      test('calls logout and deletes token', () async {
        when(mockApiService.logout(testToken)).thenAnswer((_) async => {});
        when(mockTokenStorage.deleteToken()).thenAnswer((_) async => {});

        await repository.logout(testToken);

        verify(mockApiService.logout(testToken)).called(1);
        verify(mockTokenStorage.deleteToken()).called(1);
      });

      test('throws exception when logout fails', () async {
        when(mockApiService.logout(testToken))
            .thenThrow(Exception('Logout failed'));

        expect(() => repository.logout(testToken), throwsException);
      });
    });

    group('checkToken', () {
      test('returns true when token is valid', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => testToken);
        when(mockApiService.checkToken()).thenAnswer((_) async => true);

        final result = await repository.checkToken();

        expect(result, true);
        verify(mockTokenStorage.getToken()).called(1);
        verify(mockApiService.checkToken()).called(1);
      });

      test('returns false when no token exists', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => null);

        final result = await repository.checkToken();

        expect(result, false);
        verify(mockTokenStorage.getToken()).called(1);
        verifyNever(mockApiService.checkToken());
      });

      test('returns false and deletes token when token is invalid', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => testToken);
        when(mockApiService.checkToken()).thenAnswer((_) async => false);
        when(mockTokenStorage.deleteToken()).thenAnswer((_) async => {});

        final result = await repository.checkToken();

        expect(result, false);
        verify(mockTokenStorage.deleteToken()).called(1);
      });

      test('returns false when checkToken throws exception', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => testToken);
        when(mockApiService.checkToken()).thenThrow(Exception('API error'));

        final result = await repository.checkToken();

        expect(result, false);
      });
    });

    group('getToken', () {
      test('returns token when it exists', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => testToken);

        final result = await repository.getToken();

        expect(result, testToken);
        verify(mockTokenStorage.getToken()).called(1);
      });

      test('returns null when no token exists', () async {
        when(mockTokenStorage.getToken()).thenAnswer((_) async => null);

        final result = await repository.getToken();

        expect(result, null);
      });

      test('returns null when getToken throws exception', () async {
        when(mockTokenStorage.getToken()).thenThrow(Exception('Storage error'));

        final result = await repository.getToken();

        expect(result, null);
      });
    });
  });
}