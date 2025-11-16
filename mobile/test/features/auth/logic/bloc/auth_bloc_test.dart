import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_event.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  late AuthBloc authBloc;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testToken = 'test_token_123';
    const testUsername = 'test@ex.com';
    const testAccessCode = '12345';

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        build: () {
          when(mockAuthRepository.login(testUsername, testAccessCode))
              .thenAnswer((_) async => testToken);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          LoginRequested(username: testUsername, accessCode: testAccessCode),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.token, 'token', testToken),
        ],
        verify: (_) {
          verify(mockAuthRepository.login(testUsername, testAccessCode))
              .called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when login fails',
        build: () {
          when(mockAuthRepository.login(testUsername, testAccessCode))
              .thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          LoginRequested(username: testUsername, accessCode: testAccessCode),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>().having(
            (state) => state.error,
            'error',
            isNotNull,
          ),
        ],
      );
    });

    group('AppStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when valid token exists',
        build: () {
          when(mockAuthRepository.checkToken()).thenAnswer((_) async => true);
          when(mockAuthRepository.getToken()).thenAnswer((_) async => testToken);
          return authBloc;
        },
        act: (bloc) => bloc.add(AppStarted()),
        expect: () => [
          isA<AuthAuthenticated>()
              .having((state) => state.token, 'token', testToken),
        ],
        verify: (_) {
          verify(mockAuthRepository.checkToken()).called(1);
          verify(mockAuthRepository.getToken()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when no token exists',
        build: () {
          when(mockAuthRepository.checkToken()).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(AppStarted()),
        expect: () => [isA<AuthUnauthenticated>()],
        verify: (_) {
          verify(mockAuthRepository.checkToken()).called(1);
          verifyNever(mockAuthRepository.getToken());
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when token is invalid',
        build: () {
          when(mockAuthRepository.checkToken()).thenAnswer((_) async => true);
          when(mockAuthRepository.getToken()).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(AppStarted()),
        expect: () => [isA<AuthUnauthenticated>()],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
        build: () {
          when(mockAuthRepository.logout(testToken))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested(token: testToken)),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(mockAuthRepository.logout(testToken)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] even when logout fails',
        build: () {
          when(mockAuthRepository.logout(testToken))
              .thenThrow(Exception('Logout failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested(token: testToken)),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );
    });
  });
}