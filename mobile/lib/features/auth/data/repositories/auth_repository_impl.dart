import 'package:mobile/features/auth/data/models/login_request.dart';
import 'package:mobile/features/auth/data/repositories/auth_api_service.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';
import 'package:mobile/features/auth/logic/exception/api_exception.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthApiService apiService;
  final TokenStorageService tokenStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.tokenStorage,
  });

  @override
  Future<String> login(String username, String accessCode) async {
    try {
      final request = LoginRequest(
        username: username,
        accessCode: accessCode,
      );
      final response = await apiService.login(request);
      
      await tokenStorage.saveToken(response.token);
  
      return response.token;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await apiService.logout(token);
      await tokenStorage.deleteToken();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkToken() async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      final isValid = await apiService.checkToken();
      if (!isValid) {
        await tokenStorage.deleteToken();
        return false;
      }
      return true;
      
    } catch (e) {
      print('[AuthRepository] Erreur vérification token: $e');
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await tokenStorage.getToken();
    } catch (e) {
      return null;
    }
  }
}