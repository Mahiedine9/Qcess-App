import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:mobile/core/network/interceptors/error_interceptor.dart';
import 'package:mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:mobile/core/services/socket_dispatcher.dart';
import 'package:mobile/features/auth/data/repositories/auth_api_service.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/data/repositories/dashboard_user_repository.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/profile/data/repositories/profile_repository.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';
import 'package:mobile/features/maintenance/data/repositories/i_maintenance_repository.dart';
import 'package:mobile/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';
import 'package:mobile/features/notification/data/repositories/i_device_token_repository.dart';
import 'package:mobile/features/notification/data/repositories/device_token_repository.dart';
import 'package:mobile/features/notification/data/repositories/i_notification_repository.dart';
import 'package:mobile/features/notification/data/repositories/notification_repository.dart';
import 'package:mobile/features/notification/logic/bloc/push_notification_bloc.dart';
import 'package:mobile/features/profile/data/repositories/i_profile_repository.dart';
import 'package:mobile/features/profile/logic/bloc/profile_bloc.dart';
import 'package:mobile/features/access/data/repositories/i_access_repository.dart';
import 'package:mobile/features/access/data/repositories/access_repository.dart';
import 'package:mobile/features/access/data/repositories/i_zone_repository.dart';
import 'package:mobile/features/access/data/repositories/zone_repository.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_bloc.dart';
import 'package:mobile/core/services/socket_service.dart';
import 'package:mobile/core/services/realtime_session_manager.dart';

final sl = GetIt.instance;

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
const String websocketUrl = String.fromEnvironment(
  'WS_BASE_URL',
  defaultValue: 'http://localhost:8080/ws',
);
const Duration httpTimeout = Duration(seconds: 30);

Future<void> initDependencies() async {
  await initNetworkDependencies();
  await initAuthFeature();
  await initSplashFeature();
  await initHomeFeature();
  await initMaintenanceFeature();
  await initProfileFeature();
  await initNotificationFeature();
  await initAccessFeature();
}

Future<void> initNetworkDependencies() async {
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());

  sl.registerLazySingleton<Dio>(() => _buildDio(sl<TokenStorageService>()));
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
  sl.registerLazySingleton<SplashBloc>(() => SplashBloc());
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
    () => DashboardUserRepository(sl<Dio>(), sl<IAccessRepository>()),
  );

  sl.registerLazySingleton<DashboardBloc>(
    () =>
        DashboardBloc(dashboardUserRepository: sl<IDashboardUserRepository>()),
  );
}

Future<void> initMaintenanceFeature() async {
  sl.registerLazySingleton<IMaintenanceRepository>(
    () => MaintenanceRepository(sl<Dio>()),
  );

  sl.registerFactory<TicketsBloc>(
    () => TicketsBloc(maintenanceRepository: sl<IMaintenanceRepository>()),
  );
}

Future<void> initProfileFeature() async {
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepository(sl<Dio>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: sl<IProfileRepository>()),
  );
}

Future<void> initNotificationFeature() async {
  sl.registerLazySingleton<IDeviceTokenRepository>(
    () => PushNotificationRepository(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepository(sl<Dio>()),
  );

  sl.registerLazySingleton<PushNotificationBloc>(
    () => PushNotificationBloc(
      repository: sl<IDeviceTokenRepository>(),
      notificationRepository: sl<INotificationRepository>(),
    ),
  );

  sl.registerLazySingleton<SocketService>(
    () => SocketService(websocketUrl: websocketUrl),
  );
  sl.registerLazySingleton<SocketDispatcher>(() => SocketDispatcher());
  sl.registerLazySingleton<RealtimeSessionManager>(() => RealtimeSessionManager(
        socket: sl<SocketService>(),
        dispatcher: sl<SocketDispatcher>(),
      ));
}

Future<void> initAccessFeature() async {
  sl.registerLazySingleton<IAccessRepository>(
    () => AccessRepository(sl<Dio>()),
  );

  sl.registerLazySingleton<IZoneRepository>(
    () => ZoneRepository(sl<Dio>()),
  );

  sl.registerFactory<AccessBloc>(
    () => AccessBloc(repository: sl<IAccessRepository>()),
  );
}
