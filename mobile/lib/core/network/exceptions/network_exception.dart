abstract class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends NetworkException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends NetworkException {
  NotFoundException(String message) : super(message, 404);
}

class BadRequestException extends NetworkException {
  BadRequestException(String message) : super(message, 400);
}

class ServerException extends NetworkException {
  ServerException(String message, [int? statusCode])
      : super(message, statusCode ?? 500);
}

class ConnectionException extends NetworkException {
  ConnectionException(String message) : super(message, null);
}

class TimeoutException extends NetworkException {
  TimeoutException(String message) : super(message, null);
}