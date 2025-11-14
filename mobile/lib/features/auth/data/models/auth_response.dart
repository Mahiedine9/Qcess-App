class AuthResponse {
  final String token;
  final String email;
  final String? fullName;
  final String role;
  final String organization;

  AuthResponse({
    required this.token,
    required this.email,
    this.fullName,
    required this.role,
    required this.organization,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      organization: json['organization'],
    );
  }
}