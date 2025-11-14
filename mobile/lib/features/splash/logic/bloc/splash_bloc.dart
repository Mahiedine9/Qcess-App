import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/splash/logic/bloc/splash_event.dart';
import 'package:mobile/features/splash/logic/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final IAuthRepository authRepository;

  SplashBloc({required this.authRepository}) : super(const SplashInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashAnimating());

    await Future.delayed(const Duration(milliseconds: 2500));

    final hasToken = await authRepository.checkToken();
    print('[SplashBloc] ${hasToken ? ' Token trouvé' : ' Pas de token'}');

    if (hasToken) {
      emit(const SplashAuthenticated());
    } else {
      emit(const SplashUnauthenticated());
    }

    emit(const SplashCompleted());
  }
}
