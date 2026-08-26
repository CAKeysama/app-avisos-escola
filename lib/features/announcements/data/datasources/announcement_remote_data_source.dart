import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/mock_data_service.dart';
import '../models/announcement_model.dart';

abstract class AnnouncementRemoteDataSource {
  Stream<List<AnnouncementModel>> watchAnnouncements({
    String? courseId,
    String? classId,
  });

  Future<AnnouncementModel?> getAnnouncementById(String id);
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement);
  Future<AnnouncementModel> updateAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String id);
  Future<void> markAsRead(String announcementId, String userId);
  Future<void> togglePin(String id, bool isPinned);
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final SharedPreferences _prefs;
  final _streamController = StreamController<List<AnnouncementModel>>.broadcast();
  final List<AnnouncementModel> _cachedAnnouncements = [];
  final Set<String> _readAnnouncementIds = {};

  AnnouncementRemoteDataSourceImpl(this._prefs) {
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    // Carrega avisos salvos localmente
    final rawJson = _prefs.getString(AppConstants.collectionAnnouncements);
    final rawReads = _prefs.getStringList(AppConstants.collectionReads) ?? [];
    _readAnnouncementIds.addAll(rawReads);

    if (rawJson != null) {
      try {
        final list = jsonDecode(rawJson) as List<dynamic>;
        _cachedAnnouncements.clear();
        for (var item in list) {
          final model = AnnouncementModel.fromJson(item as Map<String, dynamic>);
          _cachedAnnouncements.add(
            model.copyWith(isRead: _readAnnouncementIds.contains(model.id)),
          );
        }
      } catch (_) {
        _populateInitialMocks();
      }
    } else {
      _populateInitialMocks();
    }

    _sortAndEmit();
  }

  void _populateInitialMocks() {
    _cachedAnnouncements.clear();
    for (var entity in MockDataService.initialAnnouncements) {
      final model = AnnouncementModel.fromEntity(entity);
      _cachedAnnouncements.add(
        model.copyWith(isRead: _readAnnouncementIds.contains(model.id)),
      );
    }
    _persist();
  }

  Future<void> _persist() async {
    final list = _cachedAnnouncements.map((a) => a.toJson()).toList();
    await _prefs.setString(AppConstants.collectionAnnouncements, jsonEncode(list));
    await _prefs.setStringList(AppConstants.collectionReads, _readAnnouncementIds.toList());
  }

  void _sortAndEmit() {
    _cachedAnnouncements.sort((a, b) {
      // 1º: Fixados no topo
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // 2º: Data de criação decrescente
      return b.createdAt.compareTo(a.createdAt);
    });
    _streamController.add(List.unmodifiable(_cachedAnnouncements));
  }

  @override
  Stream<List<AnnouncementModel>> watchAnnouncements({
    String? courseId,
    String? classId,
  }) async* {
    yield List.unmodifiable(_cachedAnnouncements);
    yield* _streamController.stream;
  }

  @override
  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      return _cachedAnnouncements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _cachedAnnouncements.insert(0, announcement);
    await _persist();
    _sortAndEmit();
    return announcement;
  }

  @override
  Future<AnnouncementModel> updateAnnouncement(AnnouncementModel announcement) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _cachedAnnouncements.indexWhere((a) => a.id == announcement.id);
    if (index != -1) {
      _cachedAnnouncements[index] = announcement;
      await _persist();
      _sortAndEmit();
    }
    return announcement;
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedAnnouncements.removeWhere((a) => a.id == id);
    _readAnnouncementIds.remove(id);
    await _persist();
    _sortAndEmit();
  }

  @override
  Future<void> markAsRead(String announcementId, String userId) async {
    _readAnnouncementIds.add(announcementId);
    final index = _cachedAnnouncements.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      _cachedAnnouncements[index] = _cachedAnnouncements[index].copyWith(isRead: true);
      await _persist();
      _sortAndEmit();
    }
  }

  @override
  Future<void> togglePin(String id, bool isPinned) async {
    final index = _cachedAnnouncements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _cachedAnnouncements[index] = _cachedAnnouncements[index].copyWith(isPinned: isPinned);
      await _persist();
      _sortAndEmit();
    }
  }
}
