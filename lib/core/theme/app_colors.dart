import 'package:flutter/material.dart';

/// Paleta de cores do Design System FATEC / Institucional com inspiração Apple.
class AppColors {
  AppColors._();

  // Cores Primárias (Azul Institucional FATEC)
  static const Color primary = Color(0xFF005A9C);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF003E6D);
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimaryContainer = Color(0xFF00325B);

  // Cores de Apoio
  static const Color accent = Color(0xFF0284C7);
  static const Color secondary = Color(0xFF334155);

  // Superfícies e Fundos (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Tipografia (Light Mode)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Superfícies e Fundos (Dark Mode - Apple Dark Slate)
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color surfaceDark = Color(0xFF151D2A);
  static const Color cardDark = Color(0xFF1A2434);
  static const Color borderDark = Color(0xFF26354A);
  static const Color dividerDark = Color(0xFF1E293B);

  // Tipografia (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semáforo de Prioridades (Discreto e Elegante)
  static const Color priorityNormal = Color(0xFF0284C7);
  static const Color priorityNormalBg = Color(0xFFE0F2FE);
  static const Color priorityImportant = Color(0xFFD97706);
  static const Color priorityImportantBg = Color(0xFFFEF3C7);
  static const Color priorityUrgent = Color(0xFFDC2626);
  static const Color priorityUrgentBg = Color(0xFFFEE2E2);

  // Categorias
  static const Color categoryGeneral = Color(0xFF64748B);
  static const Color categoryAcademic = Color(0xFF2563EB);
  static const Color categoryClass = Color(0xFF059669);
  static const Color categoryExam = Color(0xFFD97706);
  static const Color categoryHomework = Color(0xFF7C3AED);
  static const Color categoryEvent = Color(0xFFDB2777);
  static const Color categoryAdmin = Color(0xFF475569);
  static const Color categoryRoomChange = Color(0xFFEA580C);
  static const Color categoryCancellation = Color(0xFFDC2626);
  static const Color categoryDeadline = Color(0xFF9333EA);

  // Estados
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
