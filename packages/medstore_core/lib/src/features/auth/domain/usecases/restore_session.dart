import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/session_user.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

/// Reopens the last session at start-up. A stored session from the other app's role is dropped.
class RestoreSession implements UseCase<SessionUser?, NoParams> {
  const RestoreSession(this._repository, {required this.allowedRole});

  final AuthRepository _repository;
  final UserRole allowedRole;

  @override
  Future<Result<SessionUser?>> call(NoParams params) async {
    final result = await _repository.restoreSession();
    if (result case Ok(:final value?) when value.role != allowedRole) {
      await _repository.signOut();
      return const Result.ok(null);
    }
    return result;
  }
}
