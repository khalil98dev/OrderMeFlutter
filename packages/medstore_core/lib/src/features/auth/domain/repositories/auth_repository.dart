import '../../../../core/result/result.dart';
import '../entities/session_user.dart';

/// Implemented in the data layer (API + secure storage). The domain only knows this contract.
abstract interface class AuthRepository {
  Future<Result<SessionUser>> signIn({required String userName, required String password});

  /// Restores the session from the stored refresh token; `Ok(null)` when there is none or the server
  /// ended it. Offline, it returns the last known user so the app opens on cached data.
  Future<Result<SessionUser?>> restoreSession();

  /// Ends the session on the server (best effort) and forgets tokens and cached data on this device.
  Future<Result<void>> signOut();

  /// Changes the password. The server then ends every session, this one included, so the repository
  /// signs in again with the new password to keep this device signed in.
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  /// Fires when the server ends the session (refresh refused, password changed elsewhere).
  Stream<void> get sessionExpired;
}
