import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/role_requests_controller.dart';

// Provider do tema (Light / Dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Não conectado.')));
    }

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary = isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          'Perfil',
          style: AppTypography.navTitle.copyWith(color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: accent),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),
      body: ListView(
        children: [
          // ── Header do perfil — estilo iOS Contatos ──────────────────────
          Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
            child: Row(
              children: [
                // Avatar grande
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.fillDark
                        : AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nome + cargo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTypography.title2.copyWith(
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        style: AppTypography.footnote.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Badge de papel — discreto
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role.label,
                          style: AppTypography.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Seção: Informações Acadêmicas ────────────────────────────────
          _SectionHeader(label: 'INFORMAÇÕES ACADÊMICAS', textTertiary: textTertiary),
          _GroupedSection(
            surface: surface,
            separator: separator,
            children: [
              _InfoRow(label: 'Instituição', value: user.institution, textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'Curso', value: user.courseName ?? 'Não vinculado', textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'Semestre', value: '${user.semester ?? 1}º Semestre', textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'Turma', value: user.className ?? 'Geral', textPrimary: textPrimary, textSecondary: textSecondary),
            ],
          ),

          // ── Seção: Solicitação de Cargo ────────────────────────────────────
          _SectionHeader(label: 'CARGO E PERMISSÕES', textTertiary: textTertiary),
          _GroupedSection(
            surface: surface,
            separator: separator,
            children: [
              _SettingsRow(
                label: 'Solicitar Novo Cargo / Promoção',
                icon: Icons.badge_outlined,
                iconColor: accent,
                surface: surface,
                textPrimary: textPrimary,
                textTertiary: textTertiary,
                onTap: () => _showRoleRequestSheet(
                  context,
                  ref,
                  user,
                  surface,
                  separator,
                  textPrimary,
                  textSecondary,
                  accent,
                ),
              ),
            ],
          ),

          // ── Seção: Aparência ─────────────────────────────────────────────
          _SectionHeader(label: 'APARÊNCIA', textTertiary: textTertiary),
          _GroupedSection(
            surface: surface,
            separator: separator,
            children: [
              _SettingsSwitch(
                label: 'Modo Escuro',
                value: isDark,
                surface: surface,
                textPrimary: textPrimary,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state =
                      val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ],
          ),



          const SizedBox(height: 32),

          // ── Botão Sair — estilo iOS (texto vermelho, sem botão cheio) ────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _GroupedSection(
              surface: surface,
              separator: separator,
              children: [
                _DestructiveRow(
                  label: 'Sair da Conta',
                  surface: surface,
                  onTap: () => _logout(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showRoleRequestSheet(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
    Color surface,
    Color separator,
    Color textPrimary,
    Color textSecondary,
    Color accent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 16),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Text(
                    'Solicitar Alteração de Cargo',
                    style: AppTypography.headline.copyWith(color: textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Selecione o novo cargo pretendido. A solicitação será avaliada pelo Coordenador, membros do CLI ou Admins.',
                    style: AppTypography.caption.copyWith(color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(height: 0.5, color: separator),
                ...UserRole.values
                    .where((r) => r != user.role)
                    .map((role) {
                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.transparent,
                        title: Text(
                          role.label,
                          style: AppTypography.body.copyWith(color: textPrimary),
                        ),
                        subtitle: Text(
                          _roleDescription(role),
                          style: AppTypography.caption.copyWith(color: textSecondary),
                        ),
                        trailing: Icon(
                          role == UserRole.admin ? Icons.verified_user_rounded : Icons.send_rounded,
                          size: 16,
                          color: accent,
                        ),
                        onTap: () async {
                          if (role == UserRole.admin) {
                            // Promove o usuário diretamente a Admin no Cloud Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
                                .update({'role': role.name});

                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sua conta foi definida como Administrador Geral!'),
                                ),
                              );
                            }
                          } else {
                            ref.read(roleRequestsProvider.notifier).requestRoleChange(
                                  user: user,
                                  requestedRole: role,
                                );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Solicitação para "${role.label}" enviada com sucesso aos Coordenadores/CLI!',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Container(
                        height: 0.5,
                        color: separator,
                        margin: const EdgeInsets.only(left: 16),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Sessão'),
        content: const Text(
            'Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.destructive),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }

  String _roleDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Visualiza e marca avisos como lidos';
      case UserRole.representative:
        return 'Publica avisos para sua turma';
      case UserRole.teacher:
        return 'Publica avisos para suas turmas';
      case UserRole.cli:
        return 'Publica para toda a instituição e gerencia cargos';
      case UserRole.coordinator:
        return 'Publica e fixa avisos para o curso e gerencia cargos';
      case UserRole.admin:
        return 'Acesso irrestrito a todas as áreas';
    }
  }
}

// ── Componentes internos ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textTertiary;
  const _SectionHeader({required this.label, required this.textTertiary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final Color surface;
  final Color separator;
  final List<Widget> children;
  const _GroupedSection({
    required this.surface,
    required this.separator,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Container(
                  height: 0.5,
                  color: separator,
                  margin: const EdgeInsets.only(left: 16),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTypography.subheadline.copyWith(color: textPrimary),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: AppTypography.subheadline.copyWith(color: textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color surface;
  final Color textPrimary;
  final Color textTertiary;
  final VoidCallback onTap;
  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.surface,
    required this.textPrimary,
    required this.textTertiary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
      title: Text(
        label,
        style: AppTypography.subheadline.copyWith(color: textPrimary),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: textTertiary,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Color surface;
  final Color textPrimary;
  final ValueChanged<bool> onChanged;
  const _SettingsSwitch({
    required this.label,
    required this.value,
    required this.surface,
    required this.textPrimary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      tileColor: Colors.transparent,
      title: Text(
        label,
        style: AppTypography.subheadline.copyWith(color: textPrimary),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DestructiveRow extends StatelessWidget {
  final String label;
  final Color surface;
  final VoidCallback onTap;
  const _DestructiveRow({
    required this.label,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      title: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: AppColors.destructive,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      onTap: onTap,
    );
  }
}
