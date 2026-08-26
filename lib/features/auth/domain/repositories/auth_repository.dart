import '../entities/user_entity.dart';

/// Interface do repositório de autenticação na camada de Domínio.
abstract class AuthRepository {
  /// Retorna o fluxo de alteração de autenticação do usuário
  Stream<UserEntity?> get authStateChanges;

  /// Retorna o usuário logado atualmente (ou null)
  Future<UserEntity?> getCurrentUser();

  /// Realiza login com email e senha
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Realiza cadastro de novo usuário
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? courseId,
    String? courseName,
    int? semester,
    String? classId,
    String? className,
  });

  /// Envia e-mail de redefinição de senha
  Future<void> sendPasswordResetEmail(String email);

  /// Atualiza os dados de perfil do usuário
  Future<UserEntity> updateProfile(UserEntity user);

  /// Encerra a sessão
  Future<void> logout();
}
