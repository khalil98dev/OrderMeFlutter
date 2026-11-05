import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../repositories/auth_repository.dart';

final class ChangePasswordParams {
  const ChangePasswordParams({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;
}

/// Changes the signed-in user's password. Every other device is signed out; this one stays signed in.
class ChangePassword implements UseCase<void, ChangePasswordParams> {
  const ChangePassword(this._repository);

  /// The server's rule.
  static const minLength = 8;

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ChangePasswordParams params) =>
      _repository.changePassword(currentPassword: params.currentPassword, newPassword: params.newPassword);
}
