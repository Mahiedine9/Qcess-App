import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/exception/api_exception.dart';
import 'package:mobile/features/auth/logic/bloc/auth_event.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final IAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AppStarted>(_onAppStart);
  }

  Future<void> _onAppStart(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final hasToken = await authRepository.checkToken();
      if (hasToken) {
        final token = await authRepository.getToken();
        if (token != null && token.isNotEmpty) {
          emit(AuthAuthenticated(token: token));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.username, event.accessCode);
      emit(AuthAuthenticated(token: token));
    } catch (e) {
      emit(AuthUnauthenticated(error: _mapExceptionToMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout(event.token);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated(error: _mapExceptionToMessage(e)));
    }
  }

  String _mapExceptionToMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    final raw = error.toString().toLowerCase();

    if (raw.contains('socketexception') ||
        raw.contains('network') ||
        raw.contains('connection') ||
        raw.contains('erreur réseau')) {
      return 'Erreur réseau : vérifiez votre connexion internet.';
    }

    if (raw.contains('401') ||
        raw.contains('unauthorized') ||
        raw.contains('invalid credentials') ||
        raw.contains('identifiants invalides')) {
      return 'Identifiants invalides. Veuillez réessayer.';
    }

    if (raw.contains('timeout') || raw.contains('délai')) {
      return 'Délai d\'attente dépassé. Veuillez réessayer.';
    }

    if (raw.contains('500') || raw.contains('server')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }

    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  
}