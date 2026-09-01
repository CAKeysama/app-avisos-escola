import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/announcement_feed_controller.dart';
import '../../domain/entities/announcement_priority.dart';

final announcementDetailProvider =
    FutureProvider.family.autoDispose((ref, String id) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final currentUser = ref.watch(authControllerProvider).user;
  final announcement = await repository.getAnnouncementById(id);

  if (announcement != null && currentUser != null) {
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
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
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

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary = isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;
    final fill = isDark ? AppColors.fillDark : AppColors.fillLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: accent),
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

                  return IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.destructive),
                    onPressed: () => _confirmDelete(context, ref),
                    tooltip: 'Excluir',
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),
      body: SafeArea(
        child: asyncDetail.when(
          loading: () => const AppLoading(message: 'Carregando...'),
          error: (err, _) => AppErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(announcementDetailProvider(announcementId)),
          ),
          data: (announcement) {
            if (announcement == null) {
              return const AppErrorView(message: 'Aviso não encontrado ou removido.');
            }

            final isUrgent = announcement.priority == AnnouncementPriority.urgent;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    // ── Título do Aviso ──────────────────────────────────
                    Text(
                      announcement.title,
                      style: AppTypography.title1.copyWith(
                        color: textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Metadados / Subtítulo discreto estilo iOS ──────────
                    Row(
                      children: [
                        // Indicator dot de categoria
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isUrgent ? AppColors.priorityUrgent : announcement.category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          announcement.category.label,
                          style: AppTypography.caption.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '  •  ${announcement.targetDisplayLabel}',
                          style: AppTypography.caption.copyWith(
                            color: textTertiary,
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.priorityUrgent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Urgente',
                              style: AppTypography.caption2.copyWith(
                                color: AppColors.priorityUrgent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (announcement.isPinned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Fixado',
                              style: AppTypography.caption2.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Seção do Autor — estilo iOS Mail (Clean Header) ────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark ? fill : AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              announcement.authorName.isNotEmpty
                                  ? announcement.authorName[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.authorName,
                                  style: AppTypography.subheadline.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  announcement.authorRole.label,
                                  style: AppTypography.caption.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(announcement.createdAt),
                            style: AppTypography.caption.copyWith(
                              color: textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Conteúdo / Descrição do Aviso ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        announcement.description,
                        style: AppTypography.body.copyWith(
                          color: textPrimary,
                          height: 1.55,
                        ),
                      ),
                    ),

                    // ── Anexo (se houver) ─────────────────────────────────
                    if (announcement.attachmentUrl != null || announcement.attachmentName != null) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'ANEXOS',
                          style: AppTypography.caption2.copyWith(
                            color: textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          tileColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.insert_drive_file_outlined, color: accent, size: 20),
                          ),
                          title: Text(
                            announcement.attachmentName ?? 'Documento_Institucional.pdf',
                            style: AppTypography.subheadline.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Toque para abrir',
                            style: AppTypography.caption.copyWith(color: textSecondary),
                          ),
                          trailing: Icon(Icons.arrow_outward_rounded, size: 18, color: textTertiary),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abrindo anexo...')),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
