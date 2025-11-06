import 'package:mobile/features/auth/data/models/User.dart';

abstract class IAuthRepository {
  Future<User?> login(String username, String accessCode);
}
