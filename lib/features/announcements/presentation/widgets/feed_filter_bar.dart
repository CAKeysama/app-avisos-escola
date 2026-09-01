import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/announcement_category.dart';
import '../controllers/announcement_feed_controller.dart';

/// Filtros de feed — barra de busca + segmented control iOS.
class FeedFilterBar extends ConsumerWidget {
  const FeedFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(feedFilterControllerProvider);
    final ctrl = ref.read(feedFilterControllerProvider.notifier);

    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barra de busca estilo iOS ──────────────────────────────────
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.fillDark : AppColors.fillLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: ctrl.setSearchQuery,
            textAlignVertical: TextAlignVertical.center,
            style: AppTypography.subheadline.copyWith(
              color: isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary,
            ),
            decoration: InputDecoration(
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Buscar',
              hintStyle: AppTypography.subheadline.copyWith(
                color: isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              suffixIcon: filterState.searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () => ctrl.setSearchQuery(''),
                      child: Icon(
                        Icons.cancel,
                        size: 16,
                        color: isDark
                            ? AppColors.labelTertiaryDark
                            : AppColors.labelTertiary,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Segmented Control estilo iOS ───────────────────────────────
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? AppColors.fillDark : AppColors.fillLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: FeedFilterType.values.map((type) {
              final isSelected = filterState.filterType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.setFilterType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      // Usar [] em vez de null permite interpolação suave
                      boxShadow: isSelected && !isDark
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _label(type),
                        style: AppTypography.caption.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? (isDark
                                  ? AppColors.labelPrimaryDark
                                  : AppColors.labelPrimary)
                              : (isDark
                                  ? AppColors.labelSecondaryDark
                                  : AppColors.labelSecondary),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Chips de categoria (discretos, apenas quando relevante) ────
        if (filterState.searchQuery.isEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AnnouncementCategory.values.map((cat) {
                final isSelected = filterState.category == cat;
                final dotColor = cat.color;
                return GestureDetector(
                  onTap: () => ctrl.toggleCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? dotColor.withOpacity(0.12)
                          : (isDark
                              ? AppColors.fillDark
                              : AppColors.fillLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat.label,
                          style: AppTypography.caption.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? dotColor
                                : (isDark
                                    ? AppColors.labelSecondaryDark
                                    : AppColors.labelSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  String _label(FeedFilterType type) {
    switch (type) {
      case FeedFilterType.all:       return 'Todos';
      case FeedFilterType.myClass:   return 'Turma';
      case FeedFilterType.myCourse:  return 'Curso';
      case FeedFilterType.school:    return 'Escola';
      case FeedFilterType.important: return 'Urgentes';
    }
  }
}
