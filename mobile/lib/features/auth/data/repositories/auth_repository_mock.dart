import 'package:mobile/features/auth/data/models/User.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';

class AuthRepositoryMock implements IAuthRepository {
  @override
  Future<User?> login(String username, String accessCode) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username == 'user1@gmail.com' && accessCode == '1234') {
      return User(username: username);
    } else {
      return null;
    }
  }
}