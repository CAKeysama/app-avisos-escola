import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_sala_avisos/core/errors/failures.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_target.dart';
import 'package:app_sala_avisos/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:app_sala_avisos/features/announcements/domain/usecases/announcement_usecases.dart';
import 'package:app_sala_avisos/features/auth/domain/entities/user_entity.dart';
import 'package:app_sala_avisos/features/auth/domain/entities/user_role.dart';

class MockAnnouncementRepository extends Mock implements AnnouncementRepository {}

void main() {
  late MockAnnouncementRepository mockRepository;
  late CreateAnnouncementUseCase createUseCase;

  setUpAll(() {
    registerFallbackValue(
      AnnouncementEntity(
        id: 'dummy',
        title: 'dummy',
        description: 'dummy',
        authorId: 'dummy',
        authorName: 'dummy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockAnnouncementRepository();
    createUseCase = CreateAnnouncementUseCase(mockRepository);
  });

  const mockStudent = UserEntity(
    id: 'u1',
    name: 'Aluno Teste',
    email: 'aluno@fatec.sp.gov.br',
    role: UserRole.student,
    classId: 'dsm-4-a',
    courseId: 'dsm',
  );

  const mockRepresentative = UserEntity(
    id: 'u2',
    name: 'Rep Teste',
    email: 'rep@fatec.sp.gov.br',
    role: UserRole.representative,
    classId: 'dsm-4-a',
    courseId: 'dsm',
  );

  const mockCoordinator = UserEntity(
    id: 'u3',
    name: 'Coord Teste',
    email: 'coord@fatec.sp.gov.br',
    role: UserRole.coordinator,
    courseId: 'dsm',
  );

  group('CreateAnnouncementUseCase Tests', () {
    test('should throw ValidationFailure if title is empty', () async {
      final announcement = AnnouncementEntity(
        id: 'a1',
        title: '',
        description: 'Descrição válida',
        authorId: 'u2',
        authorName: 'Rep',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetType: AnnouncementTargetType.classTarget,
        classId: 'dsm-4-a',
      );

      expect(
        () => createUseCase(announcement: announcement, author: mockRepresentative),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('should throw PermissionFailure when Student tries to create announcement', () async {
      final announcement = AnnouncementEntity(
        id: 'a1',
        title: 'Aviso Aluno',
        description: 'Descrição válida',
        authorId: 'u1',
        authorName: 'Aluno',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetType: AnnouncementTargetType.classTarget,
        classId: 'dsm-4-a',
      );

      expect(
        () => createUseCase(announcement: announcement, author: mockStudent),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('should throw PermissionFailure when Representative tries to create announcement for another class', () async {
      final announcement = AnnouncementEntity(
        id: 'a1',
        title: 'Aviso Outra Turma',
        description: 'Descrição válida',
        authorId: 'u2',
        authorName: 'Rep',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetType: AnnouncementTargetType.classTarget,
        classId: 'ads-2-b', // Outra turma!
      );

      expect(
        () => createUseCase(announcement: announcement, author: mockRepresentative),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('should successfully create announcement when authorized', () async {
      final announcement = AnnouncementEntity(
        id: 'a1',
        title: 'Aviso Geral da Escola',
        description: 'Descrição válida institucional',
        authorId: 'u3',
        authorName: 'Coord',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetType: AnnouncementTargetType.school,
      );

      when(() => mockRepository.createAnnouncement(any()))
          .thenAnswer((_) async => announcement);

      final result = await createUseCase(
        announcement: announcement,
        author: mockCoordinator,
      );

      expect(result.id, 'a1');
      verify(() => mockRepository.createAnnouncement(any())).called(1);
    });
  });
}
