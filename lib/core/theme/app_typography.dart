import 'package:flutter/material.dart';

/// Tipografia Apple SF Pro — hierarquia clara com pouquíssimos níveis.
class AppTypography {
  AppTypography._();

  // Navigation bar title
  static const TextStyle navTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Large title (tela de destaque)
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Title 1
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.21,
  );

  // Title 2
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Title 3
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Headline (list item title — semibold)
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // Body (conteúdo principal)
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.47,
  );

  // Callout
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.44,
  );

  // Subheadline
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // Footnote
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.05,
    height: 1.38,
  );

  // Caption 1
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.33,
  );

  // Caption 2 (menor)
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
    height: 1.3,
  );

  // ── Legado — para não quebrar chamadas existentes ────────────────────────
  static const TextStyle displayLarge    = largeTitle;
  static const TextStyle displayMedium   = title1;
  static const TextStyle titleLarge      = title3;
  static const TextStyle titleMedium     = headline;
  static const TextStyle titleSmall      = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1);
  static const TextStyle bodyLarge       = body;
  static const TextStyle bodyMedium      = callout;
  static const TextStyle bodySmall       = footnote;
  static const TextStyle labelLarge      = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1);
  static const TextStyle labelMedium     = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const TextStyle labelSmall      = caption2;
}
