import 'package:dio/dio.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;

  static const List<String> _publicRoutes = [
    '/api/auth/login',
    '/api/auth/refresh-token',
  ];

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicRoute(options.path)) {
      return handler.next(options);
    }

    try {
      final token = await _tokenStorage.getToken();
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
      }
    } catch (e) {
      print('[AuthInterceptor] Error retrieving token: ${e.toString()}');
    }

    return handler.next(options);
  }

  bool _isPublicRoute(String path) {
    return _publicRoutes.any((route) => path.startsWith(route));
  }
}