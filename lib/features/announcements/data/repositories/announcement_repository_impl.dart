import '../../../../core/errors/failures.dart';
import '../../domain/entities/announcement_category.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';
import '../../domain/entities/announcement_target.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_data_source.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource _remoteDataSource;

  AnnouncementRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<AnnouncementEntity>> watchAnnouncements({
    String? courseId,
    String? classId,
    AnnouncementTargetType? targetFilter,
    AnnouncementCategory? categoryFilter,
    AnnouncementPriority? priorityFilter,
    String? searchQuery,
    bool onlyImportantOrUrgent = false,
  }) {
    return _remoteDataSource
        .watchAnnouncements(courseId: courseId, classId: classId)
        .map((list) {
      return list.where((a) {
        // Filtro de Público Alvo (Segmentação Institucional)
        if (targetFilter != null && a.targetType != targetFilter) {
          return false;
        }

        // Filtro de Categoria
        if (categoryFilter != null && a.category != categoryFilter) {
          return false;
        }

        // Filtro de Prioridade
        if (priorityFilter != null && a.priority != priorityFilter) {
          return false;
        }

        // Filtro Apenas Importantes / Urgentes
        if (onlyImportantOrUrgent &&
            a.priority != AnnouncementPriority.important &&
            a.priority != AnnouncementPriority.urgent) {
          return false;
        }

        // Busca por termo
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final query = searchQuery.trim().toLowerCase();
          final matchesTitle = a.title.toLowerCase().contains(query);
          final matchesDesc = a.description.toLowerCase().contains(query);
          final matchesAuthor = a.authorName.toLowerCase().contains(query);
          if (!matchesTitle && !matchesDesc && !matchesAuthor) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  Future<AnnouncementEntity?> getAnnouncementById(String id) async {
    try {
      return await _remoteDataSource.getAnnouncementById(id);
    } catch (e) {
      throw ServerFailure('Não foi possível carregar o aviso.');
    }
  }

  @override
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement) async {
    try {
      final model = AnnouncementModel.fromEntity(announcement);
      return await _remoteDataSource.createAnnouncement(model);
    } catch (e) {
      throw ServerFailure('Falha ao publicar aviso.');
    }
  }

  @override
  Future<AnnouncementEntity> updateAnnouncement(AnnouncementEntity announcement) async {
    try {
      final model = AnnouncementModel.fromEntity(announcement);
      return await _remoteDataSource.updateAnnouncement(model);
    } catch (e) {
      throw ServerFailure('Falha ao atualizar aviso.');
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _remoteDataSource.deleteAnnouncement(id);
    } catch (e) {
      throw ServerFailure('Falha ao excluir aviso.');
    }
  }

  @override
  Future<void> markAsRead(String announcementId, String userId) async {
    try {
      await _remoteDataSource.markAsRead(announcementId, userId);
    } catch (_) {}
  }

  @override
  Future<void> togglePin(String id, bool isPinned) async {
    try {
      await _remoteDataSource.togglePin(id, isPinned);
    } catch (e) {
      throw ServerFailure('Falha ao fixar aviso.');
    }
  }
}
