import 'package:equatable/equatable.dart';

class UserDashboard extends Equatable {
  final String username;
  final String? profilePictureUrl;
  final int totalAccess;
  final DateTime? lastAccess;
  final int totalZones;

  const UserDashboard({
    required this.username,
    this.profilePictureUrl,
    required this.totalAccess,
    this.lastAccess,
    this.totalZones = 0,
  });

  @override
  List<Object?> get props => [
        username,
        profilePictureUrl,
        totalAccess,
        lastAccess,
        totalZones,
      ];
}