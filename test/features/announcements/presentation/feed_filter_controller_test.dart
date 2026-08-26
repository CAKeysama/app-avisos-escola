import 'package:flutter_test/flutter_test.dart';
import 'package:app_sala_avisos/features/announcements/domain/entities/announcement_category.dart';
import 'package:app_sala_avisos/features/announcements/presentation/controllers/announcement_feed_controller.dart';

void main() {
  group('FeedFilterController Tests', () {
    test('initial state should be default', () {
      final controller = FeedFilterController();
      expect(controller.state.filterType, FeedFilterType.all);
      expect(controller.state.category, isNull);
      expect(controller.state.searchQuery, isEmpty);
    });

    test('setFilterType should update filterType', () {
      final controller = FeedFilterController();
      controller.setFilterType(FeedFilterType.myClass);
      expect(controller.state.filterType, FeedFilterType.myClass);
    });

    test('toggleCategory should select and deselect category', () {
      final controller = FeedFilterController();
      controller.toggleCategory(AnnouncementCategory.exam);
      expect(controller.state.category, AnnouncementCategory.exam);

      // Toggle again removes filter
      controller.toggleCategory(AnnouncementCategory.exam);
      expect(controller.state.category, isNull);
    });

    test('setSearchQuery updates query', () {
      final controller = FeedFilterController();
      controller.setSearchQuery('UX Design');
      expect(controller.state.searchQuery, 'UX Design');
    });

    test('resetFilters clears all state', () {
      final controller = FeedFilterController();
      controller.setFilterType(FeedFilterType.important);
      controller.toggleCategory(AnnouncementCategory.event);
      controller.setSearchQuery('maratona');

      controller.resetFilters();
      expect(controller.state.filterType, FeedFilterType.all);
      expect(controller.state.category, isNull);
      expect(controller.state.searchQuery, isEmpty);
    });
  });
}
