import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    String? courseId,
    String? courseName,
    int? semester,
    String? classId,
    String? className,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationFailure('Informe seu nome completo');
    }
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Informe seu e-mail institucional');
    }
    if (password.length < 6) {
      throw const ValidationFailure('A senha deve possuir pelo menos 6 caracteres');
    }

    return _repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
      courseId: courseId,
      courseName: courseName,
      semester: semester,
      classId: classId,
      className: className,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email) async {
    if (email.trim().isEmpty) {
      throw const ValidationFailure('Informe o e-mail cadastrado');
    }
    return _repository.sendPasswordResetEmail(email.trim());
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity?> call() => _repository.getCurrentUser();
}

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<UserEntity> call(UserEntity user) => _repository.updateProfile(user);
}
