import 'package:flutter/material.dart';

/// Tipos de público-alvo dos avisos acadêmicos.
enum AnnouncementTargetType {
  school,
  course,
  classTarget;

  String get label {
    switch (this) {
      case AnnouncementTargetType.school:
        return 'Toda a Escola';
      case AnnouncementTargetType.course:
        return 'Curso';
      case AnnouncementTargetType.classTarget:
        return 'Turma / Sala';
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementTargetType.school:
        return Icons.account_balance_outlined;
      case AnnouncementTargetType.course:
        return Icons.school_outlined;
      case AnnouncementTargetType.classTarget:
        return Icons.group_outlined;
    }
  }

  static AnnouncementTargetType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'course':
      case 'curso':
        return AnnouncementTargetType.course;
      case 'class':
      case 'classtarget':
      case 'turma':
      case 'sala':
        return AnnouncementTargetType.classTarget;
      case 'school':
      case 'escola':
      default:
        return AnnouncementTargetType.school;
    }
  }
}
