import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/splash/logic/bloc/splash_event.dart';
import 'package:mobile/features/splash/logic/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final IAuthRepository authRepository;

  SplashBloc({required this.authRepository}) : super(const SplashInitial()) {
    on<StartSplashAnimation>(_onStartSplash);
  }

  Future<void> _onStartSplash(
    StartSplashAnimation event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashAnimating());
    await Future.delayed(const Duration(seconds: 1));

    emit(const SplashCompleted());
  }
}