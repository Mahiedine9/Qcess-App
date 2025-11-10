import 'package:get_it/get_it.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_mock.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/data/repositories/dashboard_user_repository_mock.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await initSplashFeature();
  await initAuthFeature();
  await initHomeFeature();
}

Future<void> initSplashFeature() async {
  sl.registerLazySingleton<SplashBloc>(() => SplashBloc());
}

Future<void> initAuthFeature() async {
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryMock());

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
      dashboardUserRepository: sl<IDashboardUserRepository>()
    ),
  );
}