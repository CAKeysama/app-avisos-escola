import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;
  final bool isHighlighted;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final defaultBorderColor = isHighlighted
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final cardBorder = border ??
        BorderSide(
          color: defaultBorderColor,
          width: isHighlighted ? 1.5 : 1.0,
        );

    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: AppRadius.borderLg,
        border: Border.fromBorderSide(cardBorder),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: padding ?? AppSpacing.paddingCard,
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}
