import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/manage_users_page.dart';
import '../../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../../features/announcements/presentation/pages/create_edit_announcement_page.dart';
import '../../features/announcements/presentation/pages/home_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isGoingToSplash = state.matchedLocation == '/';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToForgotPassword = state.matchedLocation == '/forgot-password';

      final isAuthRoute = isGoingToLogin || isGoingToRegister || isGoingToForgotPassword;

      if (isGoingToSplash) return null;

      // Se não autenticado e tentando acessar rota protegida
      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Se já autenticado e tentando acessar login/cadastro
      if (authState.isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // Proteção de rota administrativa por Role (Admin, Coordenador e CLI)
      if (state.matchedLocation.startsWith('/admin')) {
        if (authState.user?.role.canManageUsers != true) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/announcement/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnouncementDetailPage(announcementId: id);
        },
      ),
      GoRoute(
        path: '/create-announcement',
        builder: (context, state) => const CreateEditAnnouncementPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const ManageUsersPage(),
      ),
    ],
  );
});
