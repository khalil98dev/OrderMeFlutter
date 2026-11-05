import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// The signed-in user.
class SessionUser extends Equatable {
  const SessionUser({
    required this.id,
    required this.userName,
    required this.role,
    this.email,
    this.roleNames = const [],
  });

  final String id;
  final String userName;
  final String? email;
  final UserRole role;

  /// The server's role names ("Admin", "Storekeeper"…), for display.
  final List<String> roleNames;

  @override
  List<Object?> get props => [id, userName, email, role, roleNames];
}
