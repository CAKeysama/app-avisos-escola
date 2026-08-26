/// Classe base para falhas do domínio (Clean Architecture).
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

/// Falha de autenticação (credenciais inválidas, usuário desativado, etc)
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Falha de permissão / acesso negado (RBAC)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Falha de rede / conectividade
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet. Verifique sua rede.']);
}

/// Falha de servidor / banco de dados (Firestore)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocorreu um erro no servidor. Tente novamente mais tarde.']);
}

/// Falha de validação de formulários / entidades
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha genérica não mapeada
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocorreu um erro inesperado.']);
}
