import 'package:get_it/get_it.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_mock.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await initAuthFeature();
}

Future<void> initAuthFeature() async {
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryMock());
  sl.registerFactory(() => AuthBloc(authRepository: sl<IAuthRepository>()));
}