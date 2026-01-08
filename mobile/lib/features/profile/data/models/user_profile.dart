import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final String? userStatus;
  final int? organisationId;
  final String? organizationName;
  final String? profilePictureUrl;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.userStatus,
    this.organisationId,
    this.organizationName,
    this.profilePictureUrl,
    this.createdAt,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fullName: json['fullName'] as String?,
      role: json['role'] as String?,
      userStatus: json['userStatus'] as String?,
      organisationId: json['organisationId'] as int?,
      organizationName: json['organizationName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'role': role,
      'userStatus': userStatus,
      'organisationId': organisationId,
      'organizationName': organizationName,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? role,
    String? userStatus,
    int? organisationId,
    String? organizationName,
    String? profilePictureUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      userStatus: userStatus ?? this.userStatus,
      organisationId: organisationId ?? this.organisationId,
      organizationName: organizationName ?? this.organizationName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        fullName,
        role,
        userStatus,
        organisationId,
        organizationName,
        profilePictureUrl,
        createdAt,
      ];
}