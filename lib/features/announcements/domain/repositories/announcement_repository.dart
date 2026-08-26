import '../entities/announcement_category.dart';
import '../entities/announcement_entity.dart';
import '../entities/announcement_priority.dart';
import '../entities/announcement_target.dart';

/// Interface de repositório para avisos na camada de Domínio.
abstract class AnnouncementRepository {
  /// Retorna a lista de avisos visíveis para o usuário
  Stream<List<AnnouncementEntity>> watchAnnouncements({
    String? courseId,
    String? classId,
    AnnouncementTargetType? targetFilter,
    AnnouncementCategory? categoryFilter,
    AnnouncementPriority? priorityFilter,
    String? searchQuery,
    bool onlyImportantOrUrgent = false,
  });

  /// Busca aviso específico por ID
  Future<AnnouncementEntity?> getAnnouncementById(String id);

  /// Cria novo aviso com validação de permissões
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement);

  /// Atualiza aviso existente
  Future<AnnouncementEntity> updateAnnouncement(AnnouncementEntity announcement);

  /// Remove aviso
  Future<void> deleteAnnouncement(String id);

  /// Marca aviso como lido pelo usuário atual
  Future<void> markAsRead(String announcementId, String userId);

  /// Fixa ou desfixa aviso no topo do mural
  Future<void> togglePin(String id, bool isPinned);
}
