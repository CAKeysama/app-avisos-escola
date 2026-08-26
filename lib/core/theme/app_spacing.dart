import 'package:flutter/material.dart';

/// Espaçamentos e paddings padronizados no Design System.
class AppSpacing {
  AppSpacing._();

  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Insets comuns
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets paddingCard = EdgeInsets.all(16.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0);
  static const EdgeInsets paddingButtonSm = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
}
