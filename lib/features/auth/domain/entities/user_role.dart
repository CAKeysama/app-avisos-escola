/// Papéis e permissões (RBAC) no sistema de avisos da FATEC.
enum UserRole {
  student,
  representative,
  teacher,
  coordinator,
  admin;

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Aluno';
      case UserRole.representative:
        return 'Representante de Turma';
      case UserRole.teacher:
        return 'Professor';
      case UserRole.coordinator:
        return 'Coordenador de Curso';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  /// Pode criar avisos para turma
  bool get canCreateForClass =>
      this == UserRole.representative ||
      this == UserRole.teacher ||
      this == UserRole.coordinator ||
      this == UserRole.admin;

  /// Pode criar avisos para o curso inteiro
  bool get canCreateForCourse =>
      this == UserRole.coordinator || this == UserRole.admin;

  /// Pode criar avisos para toda a escola
  bool get canCreateForSchool =>
      this == UserRole.coordinator || this == UserRole.admin;

  /// Pode fixar avisos no mural
  bool get canPinAnnouncements =>
      this == UserRole.coordinator || this == UserRole.admin || this == UserRole.representative;

  /// Pode gerenciar usuários e cadastros
  bool get isAdmin => this == UserRole.admin;

  /// Converte string para enum de forma segura
  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'representative':
      case 'representante':
        return UserRole.representative;
      case 'teacher':
      case 'professor':
        return UserRole.teacher;
      case 'coordinator':
      case 'coordenador':
        return UserRole.coordinator;
      case 'admin':
      case 'administrador':
        return UserRole.admin;
      case 'student':
      case 'aluno':
      default:
        return UserRole.student;
    }
  }
}
