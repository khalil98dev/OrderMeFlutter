import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_pair.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/session_user.dart';
import '../models/session_user_model.dart';

/// The `/api/auth` endpoints.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Result<TokenPair>> login(String userName, String password) => _api.post(
    '/api/auth/login',
    data: {'userName': userName, 'password': password},
    options: ApiClient.anonymous,
    decode: (json) => TokenPair.fromJson(json! as Map<String, Object?>),
  );

  Future<Result<SessionUser>> me() => _api.get('/api/auth/me', decode: SessionUserModel.fromMeJson);

  Future<Result<void>> changePassword(String currentPassword, String newPassword) => _api.post(
    '/api/auth/change-password',
    data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    decode: ApiClient.ignoreBody,
  );

  Future<Result<void>> logout(String refreshToken) => _api.post(
    '/api/auth/logout',
    data: {'refreshToken': refreshToken},
    options: ApiClient.anonymous,
    decode: ApiClient.ignoreBody,
  );
}
