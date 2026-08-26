import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/announcement_category.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';
import '../../domain/entities/announcement_target.dart';

/// Modelo de dados de Aviso com serialização para Firestore e JSON.
class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.authorId,
    required super.authorName,
    super.authorRole = UserRole.student,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
    super.targetType = AnnouncementTargetType.school,
    super.targetId,
    super.courseId,
    super.classId,
    super.priority = AnnouncementPriority.normal,
    super.category = AnnouncementCategory.general,
    super.isPinned = false,
    super.isPublished = true,
    super.attachmentUrl,
    super.attachmentName,
    super.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, [String? id]) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is String) return DateTime.tryParse(val) ?? fallback;
      return fallback;
    }

    return AnnouncementModel(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Autor FATEC',
      authorRole: UserRole.fromString(json['authorRole'] as String?),
      createdAt: parseDate(json['createdAt'], DateTime.now()),
      updatedAt: parseDate(json['updatedAt'], DateTime.now()),
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'] as String) : null,
      targetType: AnnouncementTargetType.fromString(json['targetType'] as String?),
      targetId: json['targetId'] as String?,
      courseId: json['courseId'] as String?,
      classId: json['classId'] as String?,
      priority: AnnouncementPriority.fromString(json['priority'] as String?),
      category: AnnouncementCategory.fromString(json['category'] as String?),
      isPinned: json['isPinned'] as bool? ?? false,
      isPublished: json['isPublished'] as bool? ?? true,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'targetType': targetType.name,
      'targetId': targetId,
      'courseId': courseId,
      'classId': classId,
      'priority': priority.name,
      'category': category.name,
      'isPinned': isPinned,
      'isPublished': isPublished,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
    };
  }

  @override
  AnnouncementModel copyWith({
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
    return AnnouncementModel(
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

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorRole: entity.authorRole,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
      targetType: entity.targetType,
      targetId: entity.targetId,
      courseId: entity.courseId,
      classId: entity.classId,
      priority: entity.priority,
      category: entity.category,
      isPinned: entity.isPinned,
      isPublished: entity.isPublished,
      attachmentUrl: entity.attachmentUrl,
      attachmentName: entity.attachmentName,
      isRead: entity.isRead,
    );
  }
}
