import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_sala_avisos/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('DateFormatter Tests', () {
    test('formatShort formats date as dd/MM/yyyy', () {
      final date = DateTime(2026, 8, 26, 14, 30);
      expect(DateFormatter.formatShort(date), '26/08/2026');
    });

    test('formatTime formats time as HH:mm', () {
      final date = DateTime(2026, 8, 26, 14, 30);
      expect(DateFormatter.formatTime(date), '14:30');
    });

    test('formatRelative returns humanized relative text', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now), 'Agora há pouco');
      expect(
        DateFormatter.formatRelative(now.subtract(const Duration(minutes: 5))),
        'Há 5 minutos',
      );
      expect(
        DateFormatter.formatRelative(now.subtract(const Duration(hours: 3))),
        'Há 3 horas',
      );
    });
  });
}
