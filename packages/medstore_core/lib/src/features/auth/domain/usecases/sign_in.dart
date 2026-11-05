import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/session_user.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

final class SignInParams {
  const SignInParams({required this.userName, required this.password});

  final String userName;
  final String password;
}

/// Signs in, then refuses accounts that belong to the other app.
///
/// Each app registers this with its own [allowedRole]. The server still enforces every
/// permission; this only keeps an admin out of the teacher app and the reverse.
class SignIn implements UseCase<SessionUser, SignInParams> {
  const SignIn(this._repository, {required this.allowedRole});

  final AuthRepository _repository;
  final UserRole allowedRole;

  @override
  Future<Result<SessionUser>> call(SignInParams params) async {
    final result = await _repository.signIn(userName: params.userName, password: params.password);
    if (result case Ok(:final value) when value.role != allowedRole) {
      await _repository.signOut();
      return const Result.err(WrongAppFailure());
    }
    return result;
  }
}
