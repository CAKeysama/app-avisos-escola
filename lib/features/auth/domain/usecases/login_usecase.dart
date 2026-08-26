import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call({required String email, required String password}) async {
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Informe o e-mail');
    }
    if (password.isEmpty) {
      throw const ValidationFailure('Informe a senha');
    }
    return _repository.login(email: email.trim(), password: password);
  }
}
