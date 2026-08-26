import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_category.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_priority.dart';
import 'package:app_sala_avisos/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:app_sala_avisos/features/announcements/presentation/widgets/priority_badge.dart';

void main() {
  testWidgets('PriorityBadge renders correct label and icon for urgent priority',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PriorityBadge(priority: AnnouncementPriority.urgent),
        ),
      ),
    );

    expect(find.text('URGENTE'), findsOneWidget);
    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
  });

  testWidgets('AnnouncementCard renders title, category, and handles tap',
      (WidgetTester tester) async {
    bool tapped = false;

    final announcement = AnnouncementEntity(
      id: 'test_1',
      title: 'Aviso de Teste FATEC',
      description: 'Descrição detalhada do aviso para a comunidade acadêmica.',
      authorId: 'u1',
      authorName: 'Prof. Carlos',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now(),
      category: AnnouncementCategory.roomChange,
      priority: AnnouncementPriority.important,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnnouncementCard(
            announcement: announcement,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Aviso de Teste FATEC'), findsOneWidget);
    expect(find.text('Alteração de Sala'), findsOneWidget);
    expect(find.text('IMPORTANTE'), findsOneWidget);

    await tester.tap(find.text('Aviso de Teste FATEC'));
    expect(tapped, isTrue);
  });
}
