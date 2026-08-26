/// Exceção de autenticação lançada pelas camadas de data source.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

/// Exceção de servidor ou Firestore.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException: $message';
}

/// Exceção de permissões insuficientes.
class PermissionDeniedException implements Exception {
  final String message;

  const PermissionDeniedException([this.message = 'Você não possui permissão para realizar esta ação.']);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
