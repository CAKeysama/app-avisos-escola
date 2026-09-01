import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';

/// Lista de avisos estilo iOS Mail — linhas limpas, sem cards com sombra.
/// Separadores fazem a estrutura. Dot colorido comunica categoria.
class AnnouncementCard extends StatefulWidget {
  final AnnouncementEntity announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final a = widget.announcement;
    final isUnread = !a.isRead;
    final isUrgent = a.priority == AnnouncementPriority.urgent;

    final dotColor = isUrgent
        ? AppColors.priorityUrgent
        : a.category.color;

    final textPrimary =
        isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary =
        isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary =
        isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          color: surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dot colorido de categoria ─────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 12),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isUnread ? dotColor : Colors.transparent,
                    border: isUnread
                        ? null
                        : Border.all(
                            color: dotColor.withOpacity(0.4), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // ── Conteúdo principal ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho: remetente + data
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.authorName,
                            style: AppTypography.footnote.copyWith(
                              color: textSecondary,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatRelative(a.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: textTertiary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Título
                    Text(
                      a.title,
                      style: AppTypography.subheadline.copyWith(
                        color: textPrimary,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),

                    // Preview da descrição
                    Text(
                      a.description,
                      style: AppTypography.subheadline.copyWith(
                        color: textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Badge urgente/fixado — apenas quando necessário
                    if (isUrgent || a.isPinned) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (isUrgent)
                            _MiniTag(
                              label: 'Urgente',
                              color: AppColors.priorityUrgent,
                            ),
                          if (isUrgent && a.isPinned)
                            const SizedBox(width: 6),
                          if (a.isPinned)
                            _MiniTag(
                              label: 'Fixado',
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
