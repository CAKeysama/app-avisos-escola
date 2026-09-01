import 'user_role.dart';

enum RoleRequestStatus { pending, approved, rejected }

class RoleRequestEntity {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final UserRole requestedRole;
  final UserRole currentRole;
  final String? courseId;
  final String? className;
  final RoleRequestStatus status;
  final DateTime createdAt;

  const RoleRequestEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.requestedRole,
    required this.currentRole,
    this.courseId,
    this.className,
    this.status = RoleRequestStatus.pending,
    required this.createdAt,
  });

  RoleRequestEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    UserRole? requestedRole,
    UserRole? currentRole,
    String? courseId,
    String? className,
    RoleRequestStatus? status,
    DateTime? createdAt,
  }) {
    return RoleRequestEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      requestedRole: requestedRole ?? this.requestedRole,
      currentRole: currentRole ?? this.currentRole,
      courseId: courseId ?? this.courseId,
      className: className ?? this.className,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
