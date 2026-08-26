import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// Modelo de dados de usuário com serialização para JSON e Firestore.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.role = UserRole.student,
    super.courseId,
    super.courseName,
    super.semester,
    super.classId,
    super.className,
    super.institution = 'FATEC',
    super.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return UserModel(
      id: id ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      semester: json['semester'] as int?,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      institution: json['institution'] as String? ?? 'FATEC',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'courseId': courseId,
      'courseName': courseName,
      'semester': semester,
      'classId': classId,
      'className': className,
      'institution': institution,
      'photoUrl': photoUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? courseId,
    String? courseName,
    int? semester,
    String? classId,
    String? className,
    String? institution,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      institution: institution ?? this.institution,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      courseId: entity.courseId,
      courseName: entity.courseName,
      semester: entity.semester,
      classId: entity.classId,
      className: entity.className,
      institution: entity.institution,
      photoUrl: entity.photoUrl,
    );
  }
}
