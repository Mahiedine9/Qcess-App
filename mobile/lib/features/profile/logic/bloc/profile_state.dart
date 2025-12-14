import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/data/models/user_info.dart';

abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileState {
  final UserInfo profile;

  ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserInfo profile;

  ProfileUpdating({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserInfo profile;
  final String message;

  ProfileUpdateSuccess({required this.profile, required this.message});

  @override
  List<Object?> get props => [profile, message];
}

class ProfileError extends ProfileState {
  final String message;
  final UserInfo? previousProfile;

  ProfileError({required this.message, this.previousProfile});

  @override
  List<Object?> get props => [message, previousProfile];
}
