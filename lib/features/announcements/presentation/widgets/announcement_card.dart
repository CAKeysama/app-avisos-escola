import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';
import 'category_chip.dart';
import 'priority_badge.dart';
import 'target_badge.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrgent = announcement.priority == AnnouncementPriority.urgent;

    return AppCard(
      onTap: onTap,
      isHighlighted: isUrgent || announcement.isPinned,
      border: isUrgent
          ? BorderSide(color: AppColors.priorityUrgent.withOpacity(0.5), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha Superior: Tags, Categoria, Prioridade, Pin e Status Lido
          Row(
            children: [
              CategoryChip(category: announcement.category),
              const SizedBox(width: AppSpacing.xs),
              PriorityBadge(priority: announcement.priority),
              const Spacer(),
              if (announcement.isPinned) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight.withOpacity(0.15) : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.push_pin_rounded,
                        size: 12,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Fixado',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (!announcement.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Título do Aviso
          Text(
            announcement.title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Snippet da Descrição
          Text(
            announcement.description,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // Linha Inferior: Autor, Público-Alvo e Data Relativa
          Row(
            children: [
              TargetBadge(
                targetType: announcement.targetType,
                label: announcement.targetDisplayLabel,
              ),
              const Spacer(),
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatRelative(announcement.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
