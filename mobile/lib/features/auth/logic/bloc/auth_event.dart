abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String accessCode;

  LoginRequested({required this.username, required this.accessCode});
}

class LogoutRequested extends AuthEvent {
  final String token;
  LogoutRequested({required this.token});
}

class AppStarted extends AuthEvent {}