import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/mock_data_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(UserModel user, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateProfile(UserModel user);
  Future<void> logout();
}

/// Implementação do DataSource com persistência local e fallback para desenvolvimento ágil.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SharedPreferences _prefs;
  final _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  AuthRemoteDataSourceImpl(this._prefs) {
    _loadPersistedUser();
  }

  void _loadPersistedUser() {
    final userJson = _prefs.getString(AppConstants.keyAuthToken);
    if (userJson != null) {
      try {
        final data = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(data);
        _authStateController.add(_currentUser);
      } catch (_) {
        _currentUser = null;
        _authStateController.add(null);
      }
    } else {
      // Usuário padrão inicial para testes (aluno ou representante)
      _currentUser = UserModel.fromEntity(MockDataService.mockUsers.first);
      _saveUser(_currentUser!);
    }
  }

  Future<void> _saveUser(UserModel user) async {
    _currentUser = user;
    await _prefs.setString(AppConstants.keyAuthToken, jsonEncode(user.toJson()));
    _authStateController.add(_currentUser);
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Busca usuário nos mocks cadastrados
    final found = MockDataService.mockUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => MockDataService.mockUsers.first.copyWith(
        email: email.trim(),
        name: email.split('@').first,
      ),
    );

    final userModel = UserModel.fromEntity(found);
    await _saveUser(userModel);
    return userModel;
  }

  @override
  Future<UserModel> register(UserModel user, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _saveUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(AppConstants.keyAuthToken);
    _authStateController.add(null);
  }
}
