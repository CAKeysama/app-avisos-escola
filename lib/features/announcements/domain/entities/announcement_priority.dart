import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Níveis de prioridade dos avisos acadêmicos.
enum AnnouncementPriority {
  normal,
  important,
  urgent;

  String get label {
    switch (this) {
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.important:
        return 'Importante';
      case AnnouncementPriority.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementPriority.normal:
        return AppColors.priorityNormal;
      case AnnouncementPriority.important:
        return AppColors.priorityImportant;
      case AnnouncementPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AnnouncementPriority.normal:
        return AppColors.priorityNormalBg;
      case AnnouncementPriority.important:
        return AppColors.priorityImportantBg;
      case AnnouncementPriority.urgent:
        return AppColors.priorityUrgentBg;
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementPriority.normal:
        return Icons.info_outline;
      case AnnouncementPriority.important:
        return Icons.warning_amber_rounded;
      case AnnouncementPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  static AnnouncementPriority fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'urgent':
      case 'urgente':
        return AnnouncementPriority.urgent;
      case 'important':
      case 'importante':
        return AnnouncementPriority.important;
      case 'normal':
      default:
        return AnnouncementPriority.normal;
    }
  }
}
