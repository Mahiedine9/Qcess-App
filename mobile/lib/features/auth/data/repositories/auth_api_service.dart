import 'package:dio/dio.dart';
import 'package:mobile/core/network/base_api_repository.dart';
import 'package:mobile/features/auth/data/models/login_request.dart';
import 'package:mobile/features/auth/data/models/auth_response.dart';

class AuthApiService extends BaseApiRepository {
  AuthApiService({required Dio dio}) : super(dio);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final data = await post<Map<String, dynamic>>(
        '/api/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout(String token) async {
    try {
      await post<void>(
        '/api/auth/logout',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkToken() async {
    try {
      await get<String>('/api/auth/me');
      return true;
    } catch (e) {
      return false;
    }
  }
}