import 'package:mobile/features/auth/data/models/user_info.dart';

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

class UserInfoUpdated extends AuthEvent {
  final UserInfo userInfo;

  UserInfoUpdated({required this.userInfo});
}