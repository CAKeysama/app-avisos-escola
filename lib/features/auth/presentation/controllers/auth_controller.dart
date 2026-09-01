import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/login_usecase.dart';

// Provider de SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences precisa ser inicializado no main');
});

// Provider de DataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Provider de Repositório
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Providers de UseCases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(authRepositoryProvider));
});

// Estado de Autenticação
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Controller do Riverpod
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
  }) : super(const AuthState(isLoading: false)) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(clearUser: true, isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(clearUser: true, isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await loginUseCase(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '').replaceAll('AuthFailure: ', '');
      state = state.copyWith(isLoading: false, errorMessage: cleanMsg);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? courseId,
    String? courseName,
    int? semester,
    String? classId,
    String? className,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await registerUseCase(
        name: name,
        email: email,
        password: password,
        courseId: courseId,
        courseName: courseName,
        semester: semester,
        classId: classId,
        className: className,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      final cleanMsg = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthFailure: ', '')
          .replaceAll('ServerFailure: ', '');
      state = state.copyWith(isLoading: false, errorMessage: cleanMsg);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await resetPasswordUseCase(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> updateProfile(UserEntity user) async {
    try {
      final updated = await updateProfileUseCase(user);
      state = state.copyWith(user: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Alternador rápido de perfis para facilitar testes de permissões no app
  void switchDemoRole(UserRole role) {
    final demoUser = MockDataService.mockUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => MockDataService.mockUsers.first,
    );
    updateProfile(demoUser);
  }

  Future<void> logout() async {
    await logoutUseCase();
    state = const AuthState();
  }
}

// Provider principal do AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
  );
});
