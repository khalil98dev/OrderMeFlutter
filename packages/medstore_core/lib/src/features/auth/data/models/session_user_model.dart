import '../../domain/entities/session_user.dart';
import '../../domain/entities/user_role.dart';

/// Reads `GET /api/auth/me` and the copy of it kept on the device.
abstract final class SessionUserModel {
  static SessionUser fromMeJson(Object? json) {
    final map = json! as Map<String, Object?>;
    final roles = (map['roles'] as List<Object?>? ?? const []).whereType<String>();
    return SessionUser(
      id: map['userId']! as String,
      userName: map['userName']! as String,
      email: map['email'] as String?,
      role: UserRole.fromRoleNames(roles),
      roleNames: List.unmodifiable(roles),
    );
  }

  static Map<String, Object?> toStoredJson(SessionUser user) => {
    'userId': user.id,
    'userName': user.userName,
    'email': user.email,
    'roles': user.roleNames.isNotEmpty
        ? user.roleNames
        : [if (user.role == UserRole.client) 'Client' else 'Admin'],
  };
}
