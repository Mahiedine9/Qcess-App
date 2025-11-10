import 'package:equatable/equatable.dart';
import 'package:mobile/core/entities/User.dart';

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
  final User user;

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? error;

  AuthUnauthenticated({this.error});

  @override
  List<Object?> get props => [error];
}