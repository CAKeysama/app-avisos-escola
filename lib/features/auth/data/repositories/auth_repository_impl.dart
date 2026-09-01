import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final Uuid _uuid = const Uuid();

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.login(email, password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } catch (e) {
      throw ServerFailure('Não foi possível entrar. Verifique seu e-mail e senha.');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? courseId,
    String? courseName,
    int? semester,
    String? classId,
    String? className,
  }) async {
    try {
      final newUser = UserModel(
        id: 'usr_${_uuid.v4().substring(0, 8)}',
        name: name,
        email: email,
        role: UserRole.student,
        courseId: courseId,
        courseName: courseName,
        semester: semester,
        classId: classId,
        className: className,
        institution: 'FATEC',
      );

      return await _remoteDataSource.register(newUser, password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, code: e.code);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '');
      throw ServerFailure(msg.isNotEmpty ? msg : 'Não foi possível criar o cadastro. Tente novamente.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      throw ServerFailure('Não foi possível enviar o link de redefinição.');
    }
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      return await _remoteDataSource.updateProfile(userModel);
    } catch (e) {
      throw ServerFailure('Falha ao atualizar dados de perfil.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      throw ServerFailure('Erro ao encerrar sessão.');
    }
  }
}
