import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logError(err);
    return handler.next(err);
  }

  void _logError(DioException err) {
    final message = switch (err.type) {
      DioExceptionType.badResponse => _getBadResponseMessage(err.response),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Délai d\'attente dépassé',
      DioExceptionType.connectionError => 'Erreur réseau',
      DioExceptionType.unknown => _getUnknownErrorMessage(err.error),
      DioExceptionType.cancel => 'Requête annulée',
      DioExceptionType.badCertificate => 'Certificat SSL invalide',
    };
    print('[ErrorInterceptor] ${err.requestOptions.path}: $message');
  }

  String _getBadResponseMessage(Response? response) {
    if (response == null) return 'Erreur serveur';

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    return switch (statusCode) {
      400 => 'Requête invalide. Vérifiez les données envoyées.',
      401 => 'Session expirée. Veuillez vous reconnecter.',
      403 => 'Accès refusé. Vous n\'avez pas les permissions.',
      404 => 'Ressource non trouvée.',
      409 => 'Conflit : la ressource existe déjà.',
      422 => 'Données invalides : vérifiez les champs requis.',
      429 => 'Trop de requêtes. Veuillez réessayer plus tard.',
      500 => 'Erreur serveur. Réessayez plus tard.',
      502 => 'Serveur indisponible. Réessayez plus tard.',
      503 => 'Service temporairement indisponible.',
      _ => 'Erreur $statusCode : une erreur est survenue.',
    };
  }

  String _getUnknownErrorMessage(dynamic error) {
    final errorString = error?.toString().toLowerCase() ?? '';

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Erreur réseau : vérifiez votre connexion.';
    }

    if (errorString.contains('handshake') || errorString.contains('ssl')) {
      return 'Erreur de sécurité SSL. Contactez le support.';
    }

    return 'Une erreur inattendue s\'est produite.';
  }
}
