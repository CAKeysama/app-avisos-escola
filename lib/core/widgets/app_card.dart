import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Card estilo iOS — superfície branca limpa com scale ao tocar.
/// Sem sombra excessiva. Deixa separadores fazerem o trabalho estrutural.
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool isHighlighted;
  final bool noPadding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.isHighlighted = false,
    this.noPadding = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.974).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.borderLg,
            border: widget.isHighlighted
                ? Border.all(
                    color: accent.withOpacity(0.35), width: 1.2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: Padding(
              padding: widget.noPadding
                  ? EdgeInsets.zero
                  : widget.padding ??
                      const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
