class LoginRequest {
  final String username;
  final String accessCode;

  LoginRequest({required this.username, required this.accessCode});

  Map<String, dynamic> toJson() {
    return {
      'email': username,
      'loginCode': accessCode,
    };
  }
}