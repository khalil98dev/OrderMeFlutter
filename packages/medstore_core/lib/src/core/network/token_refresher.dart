import 'dart:async';

import 'package:dio/dio.dart';

import 'token_pair.dart';
import 'token_store.dart';

enum RefreshOutcome {
  /// A new pair is stored.
  refreshed,

  /// The server refused the refresh token (401): the session is over, tokens are cleared.
  rejected,

  /// The server could not be reached. The session is kept; try again later.
  unreachable,
}

/// Exchanges the refresh token for a new pair, **one exchange at a time**.
///
/// Refresh tokens are single use: two parallel refreshes with the same token look like a stolen token
/// and the server ends the session. Every caller that arrives while a refresh is running gets that
/// same refresh's outcome.
class TokenRefresher {
  /// [dio] must be a plain client without the auth interceptor, or a refresh could trigger a refresh.
  TokenRefresher({required Dio dio, required TokenStore store}) : _dio = dio, _store = store;

  final Dio _dio;
  final TokenStore _store;
  final _expired = StreamController<void>.broadcast();

  Future<RefreshOutcome>? _inFlight;

  /// Fires when the server ends the session (refresh rejected). The app goes to the login screen.
  Stream<void> get sessionExpired => _expired.stream;

  Future<RefreshOutcome> refresh() => _inFlight ??= _refresh().whenComplete(() => _inFlight = null);

  Future<RefreshOutcome> _refresh() async {
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) return RefreshOutcome.rejected;

    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      await _store.save(TokenPair.fromJson(response.data!));
      return RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 400) {
        await _store.clear();
        _expired.add(null);
        return RefreshOutcome.rejected;
      }
      return RefreshOutcome.unreachable;
    }
  }

  Future<void> dispose() => _expired.close();
}
