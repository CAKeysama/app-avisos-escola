import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/announcement_feed_controller.dart';
import '../widgets/announcement_card.dart';
import '../widgets/feed_filter_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final announcementsAsync = ref.watch(announcementsFeedStreamProvider);

    final canCreate = user != null &&
        (user.role.canCreateForClass ||
            user.role.canCreateForCourse ||
            user.role.canCreateForSchool);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  AppConstants.appName,
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (user != null)
              Text(
                user.academicSummary,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        actions: [
          if (user?.role.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Painel do Administrador',
              onPressed: () => context.push('/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Meu Perfil',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-announcement'),
              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_rounded, size: 20),
              label: const Text('Novo Aviso', style: AppTypography.labelMedium),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                // Saudação personalizada institucional
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.surfaceDark, AppColors.cardDark]
                              : [AppColors.primaryContainer.withOpacity(0.6), AppColors.surfaceLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.primaryLight.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, ${user?.name.split(' ').first ?? 'Estudante'} 👋',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.role.label ?? 'Mural Oficial da Instituição',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primaryLight.withOpacity(0.2) : AppColors.primary,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Text(
                              user?.courseId?.toUpperCase() ?? 'FATEC',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Barra de Filtros e Busca Fixa
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: FeedFilterBar(),
                  ),
                ),

                // Lista de Avisos Reativa
                announcementsAsync.when(
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppLoading(message: 'Carregando mural oficial...'),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorView(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(announcementsFeedStreamProvider),
                    ),
                  ),
                  data: (announcements) {
                    if (announcements.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyState(
                          title: 'Tudo em dia!',
                          message: 'Nenhum aviso encontrado para os filtros selecionados.',
                          icon: Icons.done_all_rounded,
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = announcements[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AnnouncementCard(
                                announcement: item,
                                onTap: () => context.push('/announcement/${item.id}'),
                              ),
                            );
                          },
                          childCount: announcements.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
