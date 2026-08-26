import 'package:flutter_test/flutter_test.dart';
import 'package:app_sala_avisos/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('required should return error message when value is null or empty', () {
      expect(Validators.required(null), 'Campo obrigatório');
      expect(Validators.required(''), 'Campo obrigatório');
      expect(Validators.required('   '), 'Campo obrigatório');
      expect(Validators.required('Válido'), isNull);
    });

    test('email should validate proper email format', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('invalido'), isNotNull);
      expect(Validators.email('aluno@fatec'), isNotNull);
      expect(Validators.email('aluno@fatec.sp.gov.br'), isNull);
    });

    test('password should enforce minimum 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('senha_forte_123'), isNull);
    });

    test('minLength should validate string length', () {
      expect(Validators.minLength('abc', 5), isNotNull);
      expect(Validators.minLength('abcdef', 5), isNull);
    });
  });
}
