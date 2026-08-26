import '../../../auth/domain/entities/user_role.dart';
import 'announcement_category.dart';
import 'announcement_priority.dart';
import 'announcement_target.dart';

/// Entidade de Aviso no domínio da aplicação.
class AnnouncementEntity {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final UserRole authorRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final AnnouncementTargetType targetType;
  final String? targetId;
  final String? courseId;
  final String? classId;
  final AnnouncementPriority priority;
  final AnnouncementCategory category;
  final bool isPinned;
  final bool isPublished;
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isRead;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    this.authorRole = UserRole.student,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.targetType = AnnouncementTargetType.school,
    this.targetId,
    this.courseId,
    this.classId,
    this.priority = AnnouncementPriority.normal,
    this.category = AnnouncementCategory.general,
    this.isPinned = false,
    this.isPublished = true,
    this.attachmentUrl,
    this.attachmentName,
    this.isRead = false,
  });

  /// Descrição textual do público-alvo (ex: "DSM 4º Semestre - Turma A" ou "Toda a FATEC")
  String get targetDisplayLabel {
    switch (targetType) {
      case AnnouncementTargetType.school:
        return 'Toda a Escola';
      case AnnouncementTargetType.course:
        return 'Curso: ${(courseId ?? targetId ?? '').toUpperCase()}';
      case AnnouncementTargetType.classTarget:
        return 'Turma: ${(classId ?? targetId ?? '').toUpperCase()}';
    }
  }

  AnnouncementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? authorName,
    UserRole? authorRole,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    AnnouncementTargetType? targetType,
    String? targetId,
    String? courseId,
    String? classId,
    AnnouncementPriority? priority,
    AnnouncementCategory? category,
    bool? isPinned,
    bool? isPublished,
    String? attachmentUrl,
    String? attachmentName,
    bool? isRead,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      courseId: courseId ?? this.courseId,
      classId: classId ?? this.classId,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isPublished: isPublished ?? this.isPublished,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt &&
          isRead == other.isRead;

  @override
  int get hashCode => id.hashCode ^ updatedAt.hashCode ^ isRead.hashCode;
}
