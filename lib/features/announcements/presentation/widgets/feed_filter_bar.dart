import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/announcement_category.dart';
import '../controllers/announcement_feed_controller.dart';
import 'category_chip.dart';

class FeedFilterBar extends ConsumerWidget {
  const FeedFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(feedFilterControllerProvider);
    final filterController = ref.read(feedFilterControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de Busca
        TextField(
          onChanged: filterController.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Buscar avisos por título, descrição ou autor...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: filterState.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => filterController.setSearchQuery(''),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Filtros Principais de Público / Relevância
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterSegment(
                context,
                label: 'Todos',
                isSelected: filterState.filterType == FeedFilterType.all,
                onTap: () => filterController.setFilterType(FeedFilterType.all),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _filterSegment(
                context,
                label: 'Minha Turma',
                icon: Icons.groups_outlined,
                isSelected: filterState.filterType == FeedFilterType.myClass,
                onTap: () => filterController.setFilterType(FeedFilterType.myClass),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _filterSegment(
                context,
                label: 'Meu Curso',
                icon: Icons.school_outlined,
                isSelected: filterState.filterType == FeedFilterType.myCourse,
                onTap: () => filterController.setFilterType(FeedFilterType.myCourse),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _filterSegment(
                context,
                label: 'Toda a Escola',
                icon: Icons.account_balance_outlined,
                isSelected: filterState.filterType == FeedFilterType.school,
                onTap: () => filterController.setFilterType(FeedFilterType.school),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _filterSegment(
                context,
                label: 'Importantes',
                icon: Icons.warning_amber_rounded,
                isSelected: filterState.filterType == FeedFilterType.important,
                onTap: () => filterController.setFilterType(FeedFilterType.important),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Filtros Secundários de Categoria
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AnnouncementCategory.values.map((category) {
              final isSelected = filterState.category == category;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => filterController.toggleCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _filterSegment(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeBg = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isSelected ? activeBg : borderColor,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
