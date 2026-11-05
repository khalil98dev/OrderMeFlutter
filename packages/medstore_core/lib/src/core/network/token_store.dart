import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_pair.dart';

/// Holds the session's tokens, as the backend asks: the access token **only in memory**, the refresh
/// token in secure storage (Keychain / Android Keystore / Windows Credential Manager).
class TokenStore {
  TokenStore(this._secure, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const _refreshKey = 'medstore.refresh_token';
  static const _sessionUserKey = 'medstore.session_user';

  /// Refresh a little before expiry so a request never leaves with a token that dies on the way.
  static const expiryMargin = Duration(seconds: 30);

  final FlutterSecureStorage _secure;
  final DateTime Function() _clock;

  String? _accessToken;
  DateTime? _accessExpiresAt;
  String? _refreshToken;

  String? get accessToken => _accessToken;

  /// True when there is no usable access token, or it expires within [expiryMargin].
  bool get accessTokenExpiringSoon {
    final expiresAt = _accessExpiresAt;
    return _accessToken == null || expiresAt == null || !_clock().isBefore(expiresAt.subtract(expiryMargin));
  }

  Future<String?> readRefreshToken() async => _refreshToken ??= await _secure.read(key: _refreshKey);

  Future<void> save(TokenPair pair) async {
    _accessToken = pair.accessToken;
    _accessExpiresAt = pair.accessTokenExpiresAt;
    _refreshToken = pair.refreshToken;
    await _secure.write(key: _refreshKey, value: pair.refreshToken);
  }

  /// The last signed-in user as JSON, so the app can open offline. Not a secret, but it lives with the
  /// session so it disappears with it.
  Future<String?> readSessionUser() => _secure.read(key: _sessionUserKey);

  Future<void> saveSessionUser(String json) => _secure.write(key: _sessionUserKey, value: json);

  Future<void> clear() async {
    _accessToken = null;
    _accessExpiresAt = null;
    _refreshToken = null;
    await _secure.delete(key: _refreshKey);
    await _secure.delete(key: _sessionUserKey);
  }
}
