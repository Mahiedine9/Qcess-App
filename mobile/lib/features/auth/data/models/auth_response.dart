class AuthResponse {
  final String token;
  final String email;
  final String role;
  final int organisationId;

  AuthResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.organisationId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      email: json['email'],
      role: json['role'],
      organisationId: json['organisationId'],
    );
  }
}