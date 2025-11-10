import 'package:mobile/core/entities/User.dart';

abstract class IAuthRepository {
  Future<User?> login(String username, String accessCode);
}