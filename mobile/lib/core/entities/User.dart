import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String token;
  final String email;
  final String? fullName;
  final int organisationId;
  final String role;
  final String? avatarUrl;

  const User({
    required this.token,
    required this.email,
    this.fullName,
    required this.organisationId,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [token, email, fullName, organisationId, role, avatarUrl];
}