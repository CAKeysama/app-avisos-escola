import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/announcement_remote_data_source.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement_category.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';
import '../../domain/entities/announcement_target.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/announcement_usecases.dart';

// Provider de DataSource de Avisos
final announcementDataSourceProvider = Provider<AnnouncementRemoteDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AnnouncementRemoteDataSourceImpl(prefs);
});

// Provider de Repositório de Avisos
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final ds = ref.watch(announcementDataSourceProvider);
  return AnnouncementRepositoryImpl(ds);
});

// Providers de UseCases
final getAnnouncementsUseCaseProvider = Provider<GetAnnouncementsUseCase>((ref) {
  return GetAnnouncementsUseCase(ref.watch(announcementRepositoryProvider));
});

final createAnnouncementUseCaseProvider = Provider<CreateAnnouncementUseCase>((ref) {
  return CreateAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final updateAnnouncementUseCaseProvider = Provider<UpdateAnnouncementUseCase>((ref) {
  return UpdateAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final deleteAnnouncementUseCaseProvider = Provider<DeleteAnnouncementUseCase>((ref) {
  return DeleteAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final markAnnouncementAsReadUseCaseProvider = Provider<MarkAnnouncementAsReadUseCase>((ref) {
  return MarkAnnouncementAsReadUseCase(ref.watch(announcementRepositoryProvider));
});

// Filtros do Feed
enum FeedFilterType { all, myClass, myCourse, school, important }

class FeedFilterState {
  final FeedFilterType filterType;
  final AnnouncementCategory? category;
  final AnnouncementPriority? priority;
  final String searchQuery;

  const FeedFilterState({
    this.filterType = FeedFilterType.all,
    this.category,
    this.priority,
    this.searchQuery = '',
  });

  FeedFilterState copyWith({
    FeedFilterType? filterType,
    AnnouncementCategory? category,
    bool clearCategory = false,
    AnnouncementPriority? priority,
    bool clearPriority = false,
    String? searchQuery,
  }) {
    return FeedFilterState(
      filterType: filterType ?? this.filterType,
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FeedFilterController extends StateNotifier<FeedFilterState> {
  FeedFilterController() : super(const FeedFilterState());

  void setFilterType(FeedFilterType type) {
    state = state.copyWith(filterType: type);
  }

  void toggleCategory(AnnouncementCategory cat) {
    if (state.category == cat) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: cat);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void resetFilters() {
    state = const FeedFilterState();
  }
}

final feedFilterControllerProvider =
    StateNotifierProvider<FeedFilterController, FeedFilterState>((ref) {
  return FeedFilterController();
});

// Stream Provider de Avisos Reativos
final announcementsFeedStreamProvider = StreamProvider<List<AnnouncementEntity>>((ref) {
  final getUseCase = ref.watch(getAnnouncementsUseCaseProvider);
  final filter = ref.watch(feedFilterControllerProvider);
  final currentUser = ref.watch(authControllerProvider).user;

  AnnouncementTargetType? targetFilter;
  bool onlyImportant = false;

  switch (filter.filterType) {
    case FeedFilterType.all:
      targetFilter = null;
      break;
    case FeedFilterType.myClass:
      targetFilter = AnnouncementTargetType.classTarget;
      break;
    case FeedFilterType.myCourse:
      targetFilter = AnnouncementTargetType.course;
      break;
    case FeedFilterType.school:
      targetFilter = AnnouncementTargetType.school;
      break;
    case FeedFilterType.important:
      onlyImportant = true;
      break;
  }

  return getUseCase(
    courseId: currentUser?.courseId,
    classId: currentUser?.classId,
    targetFilter: targetFilter,
    categoryFilter: filter.category,
    priorityFilter: filter.priority,
    searchQuery: filter.searchQuery,
    onlyImportantOrUrgent: onlyImportant,
  );
});
