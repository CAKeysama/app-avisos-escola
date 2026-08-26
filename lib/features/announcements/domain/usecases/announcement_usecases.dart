import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../entities/announcement_category.dart';
import '../entities/announcement_entity.dart';
import '../entities/announcement_priority.dart';
import '../entities/announcement_target.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementRepository _repository;

  GetAnnouncementsUseCase(this._repository);

  Stream<List<AnnouncementEntity>> call({
    String? courseId,
    String? classId,
    AnnouncementTargetType? targetFilter,
    AnnouncementCategory? categoryFilter,
    AnnouncementPriority? priorityFilter,
    String? searchQuery,
    bool onlyImportantOrUrgent = false,
  }) {
    return _repository.watchAnnouncements(
      courseId: courseId,
      classId: classId,
      targetFilter: targetFilter,
      categoryFilter: categoryFilter,
      priorityFilter: priorityFilter,
      searchQuery: searchQuery,
      onlyImportantOrUrgent: onlyImportantOrUrgent,
    );
  }
}

class GetAnnouncementByIdUseCase {
  final AnnouncementRepository _repository;

  GetAnnouncementByIdUseCase(this._repository);

  Future<AnnouncementEntity?> call(String id) => _repository.getAnnouncementById(id);
}

class CreateAnnouncementUseCase {
  final AnnouncementRepository _repository;

  CreateAnnouncementUseCase(this._repository);

  Future<AnnouncementEntity> call({
    required AnnouncementEntity announcement,
    required UserEntity author,
  }) async {
    if (announcement.title.trim().isEmpty) {
      throw const ValidationFailure('O título do aviso é obrigatório');
    }
    if (announcement.description.trim().isEmpty) {
      throw const ValidationFailure('A descrição do aviso é obrigatória');
    }

    // Validações de RBAC no domínio
    switch (announcement.targetType) {
      case AnnouncementTargetType.school:
        if (!author.role.canCreateForSchool) {
          throw const PermissionFailure(
              'Apenas a coordenação ou administração podem publicar avisos para toda a escola.');
        }
        break;
      case AnnouncementTargetType.course:
        if (!author.role.canCreateForCourse) {
          throw const PermissionFailure(
              'Você não possui permissão para publicar avisos para todo o curso.');
        }
        break;
      case AnnouncementTargetType.classTarget:
        if (!author.role.canCreateForClass) {
          throw const PermissionFailure(
              'Você não possui permissão para publicar avisos para turmas.');
        }
        // Se for representante, só pode publicar para a sua própria turma
        if (author.role == UserRole.representative &&
            announcement.classId != null &&
            announcement.classId != author.classId) {
          throw const PermissionFailure(
              'Representantes só podem publicar avisos para a sua respectiva turma.');
        }
        break;
    }

    return _repository.createAnnouncement(announcement);
  }
}

class UpdateAnnouncementUseCase {
  final AnnouncementRepository _repository;

  UpdateAnnouncementUseCase(this._repository);

  Future<AnnouncementEntity> call(AnnouncementEntity announcement) async {
    if (announcement.title.trim().isEmpty) {
      throw const ValidationFailure('O título do aviso é obrigatório');
    }
    if (announcement.description.trim().isEmpty) {
      throw const ValidationFailure('A descrição do aviso é obrigatória');
    }
    return _repository.updateAnnouncement(announcement);
  }
}

class DeleteAnnouncementUseCase {
  final AnnouncementRepository _repository;

  DeleteAnnouncementUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteAnnouncement(id);
}

class MarkAnnouncementAsReadUseCase {
  final AnnouncementRepository _repository;

  MarkAnnouncementAsReadUseCase(this._repository);

  Future<void> call(String announcementId, String userId) =>
      _repository.markAsRead(announcementId, userId);
}
