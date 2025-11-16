abstract class IAuthRepository {
  Future<String> login(String username, String accessCode);
  Future<void> logout(String token);
  Future<bool> checkToken();
  Future<String?> getToken();
}