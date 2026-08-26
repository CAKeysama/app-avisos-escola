import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// Provider do tema (Light / Dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Sessão'),
        content: const Text('Deseja realmente sair da sua conta institucional?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  void _showRoleSwitchDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Simular Papel / Permissão', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Alterne seu usuário instantaneamente para testar as regras de acesso de cada papel:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...UserRole.values.map((role) {
                return ListTile(
                  leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  title: Text(role.label, style: AppTypography.labelLarge),
                  subtitle: Text(_roleDescription(role), style: AppTypography.bodySmall),
                  onTap: () {
                    ref.read(authControllerProvider.notifier).switchDemoRole(role);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Alternado para perfil: ${role.label}')),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _roleDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Apenas visualiza e marca avisos como lidos';
      case UserRole.representative:
        return 'Pode publicar avisos para sua turma';
      case UserRole.teacher:
        return 'Pode publicar avisos para turmas das suas aulas';
      case UserRole.coordinator:
        return 'Pode publicar avisos para todo o curso e fixar avisos';
      case UserRole.admin:
        return 'Acesso irrestrito a todas as áreas e publicações';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Não conectado.')));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Cartão Principal do Usuário
                  AppCard(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user.name,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryLight.withOpacity(0.2) : AppColors.primaryContainer,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            user.role.label,
                            style: TextStyle(
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Informações Acadêmicas
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informações Acadêmicas', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        _infoRow('Instituição', user.institution, isDark),
                        _infoRow('Curso', user.courseName ?? 'Não vinculado', isDark),
                        _infoRow('Semestre', '${user.semester ?? 1}º Semestre', isDark),
                        _infoRow('Turma', user.className ?? 'Geral', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Preferências do Sistema
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preferências', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Modo Escuro (Dark Mode)'),
                          subtitle: const Text('Tema visual Apple Slate'),
                          value: isDark,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).state =
                                val ? ThemeMode.dark : ThemeMode.light;
                          },
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                          title: const Text('Simular outro Papel (Demo)'),
                          subtitle: const Text('Trocar entre Aluno, Representante, Professor, etc.'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showRoleSwitchDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Botão de Logout
                  AppButton(
                    text: 'Sair da Conta',
                    onPressed: () => _logout(context, ref),
                    variant: AppButtonVariant.destructive,
                    icon: Icons.logout_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
