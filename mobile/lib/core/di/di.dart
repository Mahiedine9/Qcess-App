import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:mobile/core/network/interceptors/error_interceptor.dart';
import 'package:mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:mobile/features/auth/data/repositories/auth_api_service.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/data/repositories/dashboard_user_repository_mock.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';

final sl = GetIt.instance;

const String apiBaseUrl = 'http://10.0.2.2:8080';
const Duration httpTimeout = Duration(seconds: 30);

Future<void> initDependencies() async {
  await initNetworkDependencies();
  await initAuthFeature();
  await initSplashFeature();
  await initHomeFeature();
}

Future<void> initNetworkDependencies() async {
  sl.registerLazySingleton<TokenStorageService>(
    () => TokenStorageService(),
  );

  sl.registerLazySingleton<Dio>(
    () => _buildDio(sl<TokenStorageService>()),
  );
}

Dio _buildDio(TokenStorageService tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: httpTimeout,
      receiveTimeout: httpTimeout,
      sendTimeout: httpTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(tokenStorage),
    ErrorInterceptor(),
  ]);

  return dio;
}

Future<void> initSplashFeature() async {
  sl.registerLazySingleton<SplashBloc>(
    () => SplashBloc(authRepository: sl<IAuthRepository>()),
  );
}

Future<void> initAuthFeature() async {
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      apiService: sl<AuthApiService>(),
      tokenStorage: sl<TokenStorageService>(),
    ),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: sl<IAuthRepository>()),
  );
}

Future<void> initHomeFeature() async {
  sl.registerLazySingleton<IDashboardUserRepository>(
    () => DashboardUserRepositoryMock(),
  );

  sl.registerLazySingleton<DashboardBloc>(
    () => DashboardBloc(
      dashboardUserRepository: sl<IDashboardUserRepository>(),
    ),
  );
}