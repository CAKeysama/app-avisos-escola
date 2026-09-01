import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

/// Botão estilo iOS — altura 50px, radius 13px, animação de opacidade.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isFullWidth;
  final EdgeInsets? padding;
  final double? minHeight;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isFullWidth = true,
    this.padding,
    this.minHeight,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _opacityController;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        foregroundColor = Colors.white;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.fillDark : AppColors.fillSecondLight;
        foregroundColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDark ? AppColors.primaryLight : AppColors.primary;
        border = Border.all(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 1.5,
        );
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDark ? AppColors.primaryLight : AppColors.primary;
      case AppButtonVariant.destructive:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
    }

    final buttonContent = widget.isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 19, color: foregroundColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.text,
                style: AppTypography.labelLarge.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final innerButton = GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) => _opacityController.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _opacityController.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => _opacityController.reverse(),
      child: FadeTransition(
        opacity: _opacityAnim,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.46 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            constraints:
                BoxConstraints(minHeight: widget.minHeight ?? 50),
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadius.borderMd,
              border: border,
            ),
            alignment: Alignment.center,
            child: buttonContent,
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      return SizedBox(width: double.infinity, child: innerButton);
    }
    return innerButton;
  }
}
