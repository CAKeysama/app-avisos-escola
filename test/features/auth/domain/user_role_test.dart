import 'package:flutter_test/flutter_test.dart';
import 'package:app_sala_avisos/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserRole RBAC Permissions Tests', () {
    test('Student permissions', () {
      const role = UserRole.student;
      expect(role.canCreateForClass, isFalse);
      expect(role.canCreateForCourse, isFalse);
      expect(role.canCreateForSchool, isFalse);
      expect(role.isAdmin, isFalse);
    });

    test('Representative permissions', () {
      const role = UserRole.representative;
      expect(role.canCreateForClass, isTrue);
      expect(role.canCreateForCourse, isFalse);
      expect(role.canCreateForSchool, isFalse);
      expect(role.canPinAnnouncements, isTrue);
      expect(role.isAdmin, isFalse);
    });

    test('Teacher permissions', () {
      const role = UserRole.teacher;
      expect(role.canCreateForClass, isTrue);
      expect(role.canCreateForCourse, isFalse);
      expect(role.canCreateForSchool, isFalse);
      expect(role.isAdmin, isFalse);
    });

    test('Coordinator permissions', () {
      const role = UserRole.coordinator;
      expect(role.canCreateForClass, isTrue);
      expect(role.canCreateForCourse, isTrue);
      expect(role.canCreateForSchool, isTrue);
      expect(role.canPinAnnouncements, isTrue);
      expect(role.isAdmin, isFalse);
    });

    test('Admin permissions', () {
      const role = UserRole.admin;
      expect(role.canCreateForClass, isTrue);
      expect(role.canCreateForCourse, isTrue);
      expect(role.canCreateForSchool, isTrue);
      expect(role.canPinAnnouncements, isTrue);
      expect(role.isAdmin, isTrue);
    });

    test('fromString parsing', () {
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('aluno'), UserRole.student);
      expect(UserRole.fromString('representative'), UserRole.representative);
      expect(UserRole.fromString('representante'), UserRole.representative);
      expect(UserRole.fromString('teacher'), UserRole.teacher);
      expect(UserRole.fromString('professor'), UserRole.teacher);
      expect(UserRole.fromString('coordinator'), UserRole.coordinator);
      expect(UserRole.fromString('coordenador'), UserRole.coordinator);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('unknown'), UserRole.student);
    });
  });
}
