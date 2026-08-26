import 'user_role.dart';

/// Entidade de Usuário no domínio da aplicação.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? courseId;
  final String? courseName;
  final int? semester;
  final String? classId;
  final String? className;
  final String institution;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.student,
    this.courseId,
    this.courseName,
    this.semester,
    this.classId,
    this.className,
    this.institution = 'FATEC',
    this.photoUrl,
  });

  /// Descrição resumida da turma/semestre (ex: "DSM • 4º Semestre")
  String get academicSummary {
    if (courseId == null && classId == null) {
      return role.label;
    }
    final parts = <String>[];
    if (courseId != null) parts.add(courseId!.toUpperCase());
    if (semester != null) parts.add('$semesterº Semestre');
    if (className != null && className!.isNotEmpty) {
      return parts.isEmpty ? className! : '${parts.join(' • ')} ($className)';
    }
    return parts.join(' • ');
  }

  UserEntity copyWith({
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
    return UserEntity(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}
