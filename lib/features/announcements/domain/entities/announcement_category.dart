import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Categorias de comunicação institucional.
enum AnnouncementCategory {
  general,
  academic,
  lesson,
  exam,
  homework,
  event,
  administrative,
  roomChange,
  cancellation,
  deadline;

  String get label {
    switch (this) {
      case AnnouncementCategory.general:
        return 'Geral';
      case AnnouncementCategory.academic:
        return 'Acadêmico';
      case AnnouncementCategory.lesson:
        return 'Aula';
      case AnnouncementCategory.exam:
        return 'Prova';
      case AnnouncementCategory.homework:
        return 'Trabalho';
      case AnnouncementCategory.event:
        return 'Evento';
      case AnnouncementCategory.administrative:
        return 'Administrativo';
      case AnnouncementCategory.roomChange:
        return 'Alteração de Sala';
      case AnnouncementCategory.cancellation:
        return 'Cancelamento';
      case AnnouncementCategory.deadline:
        return 'Prazo';
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementCategory.general:
        return Icons.campaign_outlined;
      case AnnouncementCategory.academic:
        return Icons.school_outlined;
      case AnnouncementCategory.lesson:
        return Icons.menu_book_outlined;
      case AnnouncementCategory.exam:
        return Icons.assignment_outlined;
      case AnnouncementCategory.homework:
        return Icons.task_alt_outlined;
      case AnnouncementCategory.event:
        return Icons.event_outlined;
      case AnnouncementCategory.administrative:
        return Icons.business_outlined;
      case AnnouncementCategory.roomChange:
        return Icons.meeting_room_outlined;
      case AnnouncementCategory.cancellation:
        return Icons.event_busy_outlined;
      case AnnouncementCategory.deadline:
        return Icons.hourglass_top_outlined;
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementCategory.general:
        return AppColors.categoryGeneral;
      case AnnouncementCategory.academic:
        return AppColors.categoryAcademic;
      case AnnouncementCategory.lesson:
        return AppColors.categoryClass;
      case AnnouncementCategory.exam:
        return AppColors.categoryExam;
      case AnnouncementCategory.homework:
        return AppColors.categoryHomework;
      case AnnouncementCategory.event:
        return AppColors.categoryEvent;
      case AnnouncementCategory.administrative:
        return AppColors.categoryAdmin;
      case AnnouncementCategory.roomChange:
        return AppColors.categoryRoomChange;
      case AnnouncementCategory.cancellation:
        return AppColors.categoryCancellation;
      case AnnouncementCategory.deadline:
        return AppColors.categoryDeadline;
    }
  }

  static AnnouncementCategory fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'academic':
      case 'acadêmico':
        return AnnouncementCategory.academic;
      case 'lesson':
      case 'aula':
        return AnnouncementCategory.lesson;
      case 'exam':
      case 'prova':
        return AnnouncementCategory.exam;
      case 'homework':
      case 'trabalho':
        return AnnouncementCategory.homework;
      case 'event':
      case 'evento':
        return AnnouncementCategory.event;
      case 'administrative':
      case 'administrativo':
        return AnnouncementCategory.administrative;
      case 'roomchange':
      case 'alteração de sala':
      case 'mudança de sala':
        return AnnouncementCategory.roomChange;
      case 'cancellation':
      case 'cancelamento':
        return AnnouncementCategory.cancellation;
      case 'deadline':
      case 'prazo':
        return AnnouncementCategory.deadline;
      case 'general':
      case 'geral':
      default:
        return AnnouncementCategory.general;
    }
  }
}
