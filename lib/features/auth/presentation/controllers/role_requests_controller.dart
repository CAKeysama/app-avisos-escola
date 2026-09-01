import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/role_request_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import 'auth_controller.dart';

final roleRequestsProvider =
    StateNotifierProvider<RoleRequestsNotifier, List<RoleRequestEntity>>((ref) {
  return RoleRequestsNotifier(ref);
});

class RoleRequestsNotifier extends StateNotifier<List<RoleRequestEntity>> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RoleRequestsNotifier(this._ref) : super([]) {
    _listenToRoleRequests();
  }

  void _listenToRoleRequests() {
    _firestore.collection('role_requests').snapshots().listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return RoleRequestEntity(
          id: doc.id,
          userId: data['userId'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          userEmail: data['userEmail'] as String? ?? '',
          requestedRole: UserRole.fromString(data['requestedRole'] as String?),
          currentRole: UserRole.fromString(data['currentRole'] as String?),
          courseId: data['courseId'] as String?,
          className: data['className'] as String?,
          status: _parseStatus(data['status'] as String?),
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = list;
    });
  }

  RoleRequestStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'approved':
        return RoleRequestStatus.approved;
      case 'rejected':
        return RoleRequestStatus.rejected;
      case 'pending':
      default:
        return RoleRequestStatus.pending;
    }
  }

  /// Solicita uma mudança de cargo para o usuário no Cloud Firestore
  Future<void> requestRoleChange({
    required UserEntity user,
    required UserRole requestedRole,
  }) async {
    final reqId = 'req_${user.id}';
    final data = {
      'id': reqId,
      'userId': user.id,
      'userName': user.name,
      'userEmail': user.email,
      'requestedRole': requestedRole.name,
      'currentRole': user.role.name,
      'courseId': user.courseId,
      'className': user.className,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('role_requests').doc(reqId).set(data);
  }

  /// Aprova uma solicitação de cargo no Firestore e atualiza o perfil do usuário
  Future<void> approveRequest(String requestId) async {
    final reqIndex = state.indexWhere((r) => r.id == requestId);
    if (reqIndex == -1) return;

    final req = state[reqIndex];

    // 1. Atualiza a solicitação no Firestore
    await _firestore.collection('role_requests').doc(requestId).update({
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Promove o usuário na coleção 'users' do Firestore
    await _firestore.collection('users').doc(req.userId).update({
      'role': req.requestedRole.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Se for o próprio usuário logado no app local
    final currentUser = _ref.read(authControllerProvider).user;
    if (currentUser != null && currentUser.id == req.userId) {
      _ref
          .read(authControllerProvider.notifier)
          .switchDemoRole(req.requestedRole);
    }
  }

  /// Recusa uma solicitação de cargo no Firestore
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('role_requests').doc(requestId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retorna apenas as solicitações pendentes
  List<RoleRequestEntity> get pendingRequests =>
      state.where((r) => r.status == RoleRequestStatus.pending).toList();
}
