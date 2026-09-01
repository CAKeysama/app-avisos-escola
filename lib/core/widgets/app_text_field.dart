import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Campo de texto estilo iOS — suporta modo agrupado (transparente) ou preenchido.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Color? fillColor;
  final bool? filled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.focusNode,
    this.fillColor,
    this.filled,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Se o usuário passou fillColor explicitamente (ex: Colors.transparent), usa ele.
    // Caso contrário, calcula a cor padrão iOS.
    final effectiveFillColor = widget.fillColor ??
        (_isFocused
            ? (isDark ? AppColors.fillDark : AppColors.fillLight)
            : (isDark ? AppColors.fillDark : AppColors.fillLight));

    final isFilled = widget.filled ?? (widget.fillColor != Colors.transparent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              widget.label!,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.labelSecondaryDark
                    : AppColors.labelSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          style: AppTypography.subheadline.copyWith(
            color: isDark
                ? AppColors.labelPrimaryDark
                : AppColors.labelPrimary,
          ),
          decoration: InputDecoration(
            filled: isFilled,
            fillColor: effectiveFillColor,
            hintText: widget.hint,
            hintStyle: AppTypography.subheadline.copyWith(
              color: isDark
                  ? AppColors.labelTertiaryDark
                  : AppColors.labelTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 19,
                    color: _isFocused
                        ? (isDark ? AppColors.primaryLight : AppColors.primary)
                        : (isDark
                            ? AppColors.labelTertiaryDark
                            : AppColors.labelTertiary),
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: isDark
                          ? AppColors.labelTertiaryDark
                          : AppColors.labelTertiary,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
