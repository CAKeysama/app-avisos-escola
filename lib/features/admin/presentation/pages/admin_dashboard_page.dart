import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../announcements/presentation/controllers/announcement_feed_controller.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final announcementsAsync = ref.watch(announcementsFeedStreamProvider);

    final totalAnnouncements = announcementsAsync.value?.length ?? 0;
    final totalCourses = MockDataService.courses.length;
    final totalClasses = MockDataService.classes.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Painel da Administração'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métricas Institucionais',
                    style: AppTypography.displayMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Visão geral de comunicação da instituição',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Cards de Métricas
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard('Avisos Ativos', '$totalAnnouncements', Icons.campaign_rounded, AppColors.primary, isDark),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _metricCard('Cursos', '$totalCourses', Icons.school_rounded, AppColors.categoryAcademic, isDark),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _metricCard('Turmas', '$totalClasses', Icons.groups_rounded, AppColors.categoryClass, isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text('Ações Administrativas', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.sm),

                  AppCard(
                    onTap: () => context.push('/admin/users'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.manage_accounts_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gerenciamento de Usuários e Permissões', style: AppTypography.labelLarge),
                              Text(
                                'Promover representantes, coordenadores e professores',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppCard(
                    onTap: () => context.push('/create-announcement'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.priorityUrgentBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notification_important_outlined, color: AppColors.priorityUrgent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Publicar Comunicado Geral (Escola)', style: AppTypography.labelLarge),
                              Text(
                                'Notificar toda a escola e alunos simultaneamente',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
