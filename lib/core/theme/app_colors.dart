import 'package:flutter/material.dart';

/// Paleta Apple HIG — "Pure White" como tema primário.
/// Baseado no iOS 17 UIKit system colors exatos.
class AppColors {
  AppColors._();

  // ── Azul Apple (único acento colorido do sistema) ────────────────────────
  static const Color primary      = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF409CFF);

  // ── Light Mode ───────────────────────────────────────────────────────────
  // Page background (cinza agrupado do iOS — fundo da página)
  static const Color backgroundLight  = Color(0xFFF2F2F7);
  // Surface branca (seções, cards, nav bar)
  static const Color surfaceLight     = Color(0xFFFFFFFF);
  // Separador — linha tênue iOS
  static const Color separatorLight   = Color(0xFFC6C6C8);
  // Fill para inputs e chips inativos
  static const Color fillLight        = Color(0xFFEFEFF4);

  // Tipografia Light
  static const Color labelPrimary     = Color(0xFF000000);
  static const Color labelSecondary   = Color(0xFF6C6C70); // secondaryLabel iOS
  static const Color labelTertiary    = Color(0xFFAEAEB2); // tertiaryLabel iOS

  // ── Dark Mode ────────────────────────────────────────────────────────────
  static const Color backgroundDark   = Color(0xFF000000);
  static const Color surfaceDark      = Color(0xFF1C1C1E);
  static const Color separatorDark    = Color(0xFF38383A);
  static const Color fillDark         = Color(0xFF2C2C2E);

  // Tipografia Dark
  static const Color labelPrimaryDark   = Color(0xFFFFFFFF);
  static const Color labelSecondaryDark = Color(0xFFAEAEB2);
  static const Color labelTertiaryDark  = Color(0xFF636366);

  // ── Semânticas (usadas com parcimônia) ───────────────────────────────────
  static const Color destructive = Color(0xFFFF3B30); // iOS Red
  static const Color success     = Color(0xFF30D158); // iOS Green
  static const Color warning     = Color(0xFFFF9F0A); // iOS Orange
  static const Color purple      = Color(0xFFBF5AF2); // iOS Purple

  // ── Categorias (dot color, não background) ───────────────────────────────
  static const Color categoryGeneral      = Color(0xFF8E8E93);
  static const Color categoryAcademic     = Color(0xFF007AFF);
  static const Color categoryClass        = Color(0xFF30D158);
  static const Color categoryExam         = Color(0xFFFF9F0A);
  static const Color categoryHomework     = Color(0xFFBF5AF2);
  static const Color categoryEvent        = Color(0xFFFF2D55);
  static const Color categoryAdmin        = Color(0xFF8E8E93);
  static const Color categoryRoomChange   = Color(0xFFFF6B00);
  static const Color categoryCancellation = Color(0xFFFF3B30);
  static const Color categoryDeadline     = Color(0xFFAF52DE);

  // Prioridade
  static const Color priorityUrgent    = Color(0xFFFF3B30);
  static const Color priorityImportant = Color(0xFFFF9F0A);
  static const Color priorityNormal    = Color(0xFF007AFF);

  // Legado — para não quebrar referências existentes
  static const Color error                 = destructive;
  static const Color accent                = primary;
  static const Color secondary             = labelSecondary;
  static const Color primaryContainer      = Color(0xFFE5F1FF);
  static const Color onPrimaryContainer    = Color(0xFF003D99);
  static const Color primaryDark           = Color(0xFF0055B3);
  static const Color cardLight             = surfaceLight;
  static const Color cardDark              = surfaceDark;
  static const Color borderLight           = separatorLight;
  static const Color borderDark            = separatorDark;
  static const Color dividerLight          = Color(0xFFE5E5EA);
  static const Color dividerDark           = Color(0xFF2C2C2E);
  static const Color textPrimaryLight      = labelPrimary;
  static const Color textSecondaryLight    = labelSecondary;
  static const Color textMutedLight        = labelTertiary;
  static const Color textPrimaryDark       = labelPrimaryDark;
  static const Color textSecondaryDark     = labelSecondaryDark;
  static const Color textMutedDark         = labelTertiaryDark;
  static const Color fillSecondLight       = fillLight;
  static const Color priorityNormalBg      = Color(0xFFE5F1FF);
  static const Color priorityImportantBg   = Color(0xFFFFF3E0);
  static const Color priorityUrgentBg      = Color(0xFFFFE5E4);
  static const Color info                  = primary;
  static const Color teal                  = Color(0xFF32ADE6);
}
