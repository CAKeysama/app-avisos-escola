import '../../features/announcements/domain/entities/announcement_category.dart';
import '../../features/announcements/domain/entities/announcement_entity.dart';
import '../../features/announcements/domain/entities/announcement_priority.dart';
import '../../features/announcements/domain/entities/announcement_target.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/entities/user_role.dart';

/// Serviço de dados iniciais para suporte offline e demonstração institucional.
class MockDataService {
  MockDataService._();

  /// Usuários de demonstração para testes rápidos
  static final List<UserEntity> mockUsers = [
    const UserEntity(
      id: 'usr_student_01',
      name: 'Gustavo Santos',
      email: 'aluno@fatec.sp.gov.br',
      role: UserRole.student,
      courseId: 'dsm',
      courseName: 'Desenvolvimento de Software Multiplataforma',
      semester: 4,
      classId: 'dsm-4-a',
      className: 'DSM 4º Semestre - Turma A',
      institution: 'FATEC São Paulo',
    ),
    const UserEntity(
      id: 'usr_rep_01',
      name: 'Mariana Lima',
      email: 'representante@fatec.sp.gov.br',
      role: UserRole.representative,
      courseId: 'dsm',
      courseName: 'Desenvolvimento de Software Multiplataforma',
      semester: 4,
      classId: 'dsm-4-a',
      className: 'DSM 4º Semestre - Turma A',
      institution: 'FATEC São Paulo',
    ),
    const UserEntity(
      id: 'usr_teacher_01',
      name: 'Prof. Carlos Eduardo',
      email: 'professor@fatec.sp.gov.br',
      role: UserRole.teacher,
      courseId: 'dsm',
      courseName: 'Desenvolvimento de Software Multiplataforma',
      semester: 4,
      classId: 'dsm-4-a',
      className: 'DSM 4º Semestre - Turma A',
      institution: 'FATEC São Paulo',
    ),
    const UserEntity(
      id: 'usr_coord_01',
      name: 'Dra. Vanessa Ribeiro',
      email: 'coordenacao@fatec.sp.gov.br',
      role: UserRole.coordinator,
      courseId: 'dsm',
      courseName: 'Desenvolvimento de Software Multiplataforma',
      institution: 'FATEC São Paulo',
    ),
    const UserEntity(
      id: 'usr_admin_01',
      name: 'Administração Acadêmica',
      email: 'admin@fatec.sp.gov.br',
      role: UserRole.admin,
      institution: 'FATEC São Paulo',
    ),
  ];

  /// Lista de cursos FATEC
  static const List<Map<String, String>> courses = [
    {'id': 'dsm', 'name': 'Desenvolvimento de Software Multiplataforma'},
    {'id': 'ads', 'name': 'Análise e Desenvolvimento de Sistemas'},
    {'id': 'ge', 'name': 'Gestão Empresarial'},
    {'id': 'log', 'name': 'Logística'},
    {'id': 'gti', 'name': 'Gestão da Tecnologia da Informação'},
  ];

  /// Lista de turmas FATEC
  static const List<Map<String, dynamic>> classes = [
    {'id': 'dsm-1-a', 'name': 'DSM 1º Semestre - Manhã', 'courseId': 'dsm'},
    {'id': 'dsm-4-a', 'name': 'DSM 4º Semestre - Turma A', 'courseId': 'dsm'},
    {'id': 'dsm-6-a', 'name': 'DSM 6º Semestre - Noite', 'courseId': 'dsm'},
    {'id': 'ads-2-b', 'name': 'ADS 2º Semestre - Turma B', 'courseId': 'ads'},
    {'id': 'ads-5-a', 'name': 'ADS 5º Semestre - Noite', 'courseId': 'ads'},
    {'id': 'ge-3-a', 'name': 'GE 3º Semestre - Manhã', 'courseId': 'ge'},
  ];

  /// Avisos acadêmicos padrão para mural inicial
  static List<AnnouncementEntity> get initialAnnouncements => [
        AnnouncementEntity(
          id: 'aviso_001',
          title: 'Manutenção no Bloco B e Suspensão das Aulas Presenciais',
          description:
              'Informamos a toda a comunidade acadêmica que no próximo sábado (29/08) haverá manutenção elétrica preventiva no Bloco B. As atividades presenciais serão realizadas de forma remota.',
          authorId: 'usr_coord_01',
          authorName: 'Dra. Vanessa Ribeiro',
          authorRole: UserRole.coordinator,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          targetType: AnnouncementTargetType.school,
          priority: AnnouncementPriority.urgent,
          category: AnnouncementCategory.cancellation,
          isPinned: true,
          isPublished: true,
        ),
        AnnouncementEntity(
          id: 'aviso_002',
          title: 'Mudança de Sala: Aula de UX & Design de Interfaces',
          description:
              'Atenção turma do 4º semestre de DSM: a aula de amanhã foi transferida temporariamente para o Laboratório 04 devido à instalação dos novos monitores.',
          authorId: 'usr_rep_01',
          authorName: 'Mariana Lima (Representante)',
          authorRole: UserRole.representative,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          targetType: AnnouncementTargetType.classTarget,
          targetId: 'dsm-4-a',
          courseId: 'dsm',
          classId: 'dsm-4-a',
          priority: AnnouncementPriority.important,
          category: AnnouncementCategory.roomChange,
          isPinned: true,
          isPublished: true,
        ),
        AnnouncementEntity(
          id: 'aviso_003',
          title: 'Prazo Final para Entrega da Sprint 2 - Projeto Integrador',
          description:
              'Lembrete importante: o envio do relatório da Sprint 2 e o link do repositório no GitHub devem ser feitos até sexta-feira às 23h59 via Teams.',
          authorId: 'usr_teacher_01',
          authorName: 'Prof. Carlos Eduardo',
          authorRole: UserRole.teacher,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          targetType: AnnouncementTargetType.course,
          targetId: 'dsm',
          courseId: 'dsm',
          priority: AnnouncementPriority.important,
          category: AnnouncementCategory.deadline,
          isPinned: false,
          isPublished: true,
        ),
        AnnouncementEntity(
          id: 'aviso_004',
          title: 'Abertura de Inscrições para a Maratona de Programação FATEC',
          description:
              'Estão abertas as inscrições para a 8ª Maratona de Programação Inter-FATECs. Equipes de até 3 alunos podem se inscrever pelo site oficial até o final do mês. Haverá premiação para os 3 primeiros colocados!',
          authorId: 'usr_admin_01',
          authorName: 'Coordenação de Extensão',
          authorRole: UserRole.admin,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          targetType: AnnouncementTargetType.school,
          priority: AnnouncementPriority.normal,
          category: AnnouncementCategory.event,
          isPinned: false,
          isPublished: true,
        ),
        AnnouncementEntity(
          id: 'aviso_005',
          title: 'Calendário de Avaliações Oficiais (P1) Publicado',
          description:
              'O calendário completo da Semana de Provas P1 já está disponível para consulta no portal acadêmico. Fiquem atentos aos dias de avaliação de cada disciplina.',
          authorId: 'usr_coord_01',
          authorName: 'Secretaria Acadêmica',
          authorRole: UserRole.coordinator,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          targetType: AnnouncementTargetType.school,
          priority: AnnouncementPriority.normal,
          category: AnnouncementCategory.exam,
          isPinned: false,
          isPublished: true,
        ),
      ];
}
