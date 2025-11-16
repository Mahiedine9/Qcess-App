import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable{}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  final String token;

  AuthAuthenticated({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthUnauthenticated extends AuthState {
  final String? error;

  AuthUnauthenticated({this.error});

  @override
  List<Object?> get props => [error];
}