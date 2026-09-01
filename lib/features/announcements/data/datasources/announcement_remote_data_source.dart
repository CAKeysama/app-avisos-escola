import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnnouncementRemoteDataSourceImpl();

  @override
  Stream<List<AnnouncementModel>> watchAnnouncements({
    String? courseId,
    String? classId,
  }) {
    return _firestore
        .collection('announcements')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return AnnouncementModel.fromJson(doc.data(), doc.id);
      }).toList();

      // Ordenação: 1º Pinned, 2º Data de Criação decrescente
      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      return list;
    });
  }

  @override
  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final doc = await _firestore.collection('announcements').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return AnnouncementModel.fromJson(doc.data()!, doc.id);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    final data = announcement.toJson();
    await _firestore.collection('announcements').doc(announcement.id).set(data);
    return announcement;
  }

  @override
  Future<AnnouncementModel> updateAnnouncement(AnnouncementModel announcement) async {
    final data = announcement.toJson();
    await _firestore.collection('announcements').doc(announcement.id).update(data);
    return announcement;
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  @override
  Future<void> markAsRead(String announcementId, String userId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (_) {}
  }

  @override
  Future<void> togglePin(String id, bool isPinned) async {
    await _firestore.collection('announcements').doc(id).update({
      'isPinned': isPinned,
    });
  }
}
