import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_role.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'aluno@fatec.sp.gov.br');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _fillDemoUser(UserRole role) {
    final demoUser = MockDataService.mockUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => MockDataService.mockUsers.first,
    );
    _emailController.text = demoUser.email;
    _passwordController.text = '123456';
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marca e Logo
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                          borderRadius: AppRadius.borderXl,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.primaryLight.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Mural Acadêmico',
                      style: AppTypography.displayMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Acesse com seu e-mail institucional FATEC',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Erro de autenticação
                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Campos de Formulário
                    AppTextField(
                      label: 'E-mail institucional',
                      hint: 'nome@fatec.sp.gov.br',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Senha',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Esqueci a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Esqueceu a senha?',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Botão Entrar
                    AppButton(
                      text: 'Entrar no Mural',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                      icon: Icons.login_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Primeiro acesso? ',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Criar conta',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    const SizedBox(height: AppSpacing.md),

                    // Acesso Rápido de Demonstração (Facilita testes do avaliador para cada perfil)
                    Text(
                      'ACESSO RÁPIDO PARA TESTES DE PERMISSÃO',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _demoRoleChip('Aluno', UserRole.student, isDark),
                        _demoRoleChip('Representante', UserRole.representative, isDark),
                        _demoRoleChip('Professor', UserRole.teacher, isDark),
                        _demoRoleChip('Coordenador', UserRole.coordinator, isDark),
                        _demoRoleChip('Admin', UserRole.admin, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoRoleChip(String label, UserRole role, bool isDark) {
    return ActionChip(
      label: Text(label, style: AppTypography.labelSmall),
      avatar: const Icon(Icons.person_outline, size: 14),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      onPressed: () => _fillDemoUser(role),
    );
  }
}
