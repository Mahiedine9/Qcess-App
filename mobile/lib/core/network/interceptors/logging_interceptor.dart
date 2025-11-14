import 'package:dio/dio.dart';

/// LoggingInterceptor log les requêtes et réponses (dev mode seulement).
///
/// Responsabilités :
/// - Logger les détails des requêtes (method, url, headers, body)
/// - Logger les réponses (status, headers, body)
/// - Logger les erreurs
/// - Désactivable en production
class LoggingInterceptor extends Interceptor {
  static const String _tag = '[HTTP]';
  static const bool _enableLogging = true;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_enableLogging) return handler.next(options);

    _logRequest(options);
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!_enableLogging) return handler.next(response);

    _logResponse(response);
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_enableLogging) return handler.next(err);

    _logError(err);
    return handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    print(
      '$_tag → ${options.method} ${options.baseUrl}${options.path}\n'
      '  Headers: ${options.headers}\n'
      '  Body: ${options.data}',
    );
  }

  void _logResponse(Response response) {
    print(
      '$_tag ← ${response.statusCode} ${response.requestOptions.path}\n'
      '  Response: ${response.data}',
    );
  }

  void _logError(DioException err) {
    print(
      '$_tag ✗ ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}\n'
      '  Error: ${err.error}\n'
      '  Message: ${err.message}',
    );
  }
}
