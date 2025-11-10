import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_event.dart';
import 'package:mobile/features/splash/logic/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashAnimating());

    await Future.delayed(const Duration(milliseconds: 2500));

    emit(const SplashCompleted());
  }
}
