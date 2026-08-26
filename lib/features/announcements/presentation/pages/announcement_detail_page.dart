import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/announcement_feed_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/priority_badge.dart';
import '../widgets/target_badge.dart';

final announcementDetailProvider =
    FutureProvider.family.autoDispose((ref, String id) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final currentUser = ref.watch(authControllerProvider).user;
  final announcement = await repository.getAnnouncementById(id);

  if (announcement != null && currentUser != null) {
    // Marca como lido automaticamente ao abrir
    await repository.markAsRead(id, currentUser.id);
  }

  return announcement;
});

class AnnouncementDetailPage extends ConsumerWidget {
  final String announcementId;

  const AnnouncementDetailPage({super.key, required this.announcementId});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Aviso'),
        content: const Text(
            'Tem certeza que deseja remover esta publicação do mural? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(deleteAnnouncementUseCaseProvider)(announcementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aviso excluído com sucesso.'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncDetail = ref.watch(announcementDetailProvider(announcementId));
    final currentUser = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detalhes do Aviso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          asyncDetail.whenOrNull(
                data: (announcement) {
                  if (announcement == null || currentUser == null) return null;

                  final canManage = currentUser.role.isAdmin ||
                      currentUser.id == announcement.authorId ||
                      (currentUser.role.canCreateForCourse &&
                          announcement.courseId == currentUser.courseId);

                  if (!canManage) return null;

                  return PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') {
                        _confirmDelete(context, ref);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text('Excluir Publicação', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: SafeArea(
        child: asyncDetail.when(
          loading: () => const AppLoading(message: 'Carregando publicação...'),
          error: (err, _) => AppErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(announcementDetailProvider(announcementId)),
          ),
          data: (announcement) {
            if (announcement == null) {
              return const AppErrorView(message: 'Aviso não encontrado ou já removido.');
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha de Badges: Categoria, Prioridade, Público
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CategoryChip(category: announcement.category),
                          PriorityBadge(priority: announcement.priority),
                          TargetBadge(
                            targetType: announcement.targetType,
                            label: announcement.targetDisplayLabel,
                          ),
                          if (announcement.isPinned)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primaryLight.withOpacity(0.15) : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.push_pin_rounded,
                                    size: 13,
                                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fixado no topo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Título Principal
                      Text(
                        announcement.title,
                        style: AppTypography.displayMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Informações do Autor e Data
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isDark ? AppColors.cardDark : AppColors.primaryContainer,
                              child: Text(
                                announcement.authorName.isNotEmpty
                                    ? announcement.authorName[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.authorName,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${announcement.authorRole.label} • Publicado em ${DateFormatter.formatDateTime(announcement.createdAt)}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Conteúdo da Descrição
                      Text(
                        announcement.description,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Anexo Opcional
                      if (announcement.attachmentUrl != null || announcement.attachmentName != null) ...[
                        Text(
                          'Anexos',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppCard(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abrindo anexo acadêmico...')),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: const Icon(Icons.attachment_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      announcement.attachmentName ?? 'Documento_Institucional.pdf',
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      'Clique para visualizar',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new_rounded, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Botão Voltar
                      AppButton(
                        text: 'Voltar ao Mural',
                        onPressed: () => context.pop(),
                        variant: AppButtonVariant.outline,
                        icon: Icons.arrow_back,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
