import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}