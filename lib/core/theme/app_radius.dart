import 'package:flutter/material.dart';

/// Bordas arredondadas exatas do iOS — Apple HIG Corner Radius.
class AppRadius {
  AppRadius._();

  static const double xs   = 6.0;
  static const double sm   = 10.0;  // iOS small control
  static const double md   = 13.0;  // iOS medium control (botões, inputs)
  static const double lg   = 16.0;  // iOS card padrão
  static const double xl   = 20.0;  // iOS card grande
  static const double xxl  = 26.0;  // iOS sheet / modal
  static const double icon  = 18.0; // iOS App Icon corner
  static const double full = 999.0;

  // BorderRadius prontos
  static final BorderRadius borderXs   = BorderRadius.circular(xs);
  static final BorderRadius borderSm   = BorderRadius.circular(sm);
  static final BorderRadius borderMd   = BorderRadius.circular(md);
  static final BorderRadius borderLg   = BorderRadius.circular(lg);
  static final BorderRadius borderXl   = BorderRadius.circular(xl);
  static final BorderRadius borderXxl  = BorderRadius.circular(xxl);
  static final BorderRadius borderIcon = BorderRadius.circular(icon);
  static final BorderRadius borderFull = BorderRadius.circular(full);
}
