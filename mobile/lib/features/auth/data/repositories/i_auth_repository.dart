import 'package:mobile/core/entities/User.dart';

abstract class IAuthRepository {
  Future<User> login(String username, String accessCode);
  Future<void> logout(String token);
  Future<bool> checkToken();
}