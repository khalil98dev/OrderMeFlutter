import 'package:dio/dio.dart';

import 'token_refresher.dart';
import 'token_store.dart';

/// Adds `Authorization: Bearer` to every request and handles expiry:
///
/// - **Before** a request: if the access token expires within 30 s, refresh first. This saves the
///   round trip of a 401 on most expiries.
/// - **After** a 401: refresh once and retry once. If another request already refreshed while this one
///   was in flight, just retry with the new token instead of refreshing again.
///
/// Requests with `extra: {AuthInterceptor.skipAuth: true}` (login, refresh, logout) are left alone.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required TokenStore store, required TokenRefresher refresher, required Dio retryClient})
    : _store = store,
      _refresher = refresher,
      _retryClient = retryClient;

  static const skipAuth = 'medstore.skipAuth';
  static const _retried = 'medstore.retried';
  static const _sentToken = 'medstore.sentToken';

  final TokenStore _store;
  final TokenRefresher _refresher;
  final Dio _retryClient;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[skipAuth] == true) return handler.next(options);

    if (_store.accessTokenExpiringSoon && await _store.readRefreshToken() != null) {
      await _refresher.refresh();
    }
    _authorize(options);
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final eligible =
        err.response?.statusCode == 401 && options.extra[skipAuth] != true && options.extra[_retried] != true;
    if (!eligible) return handler.next(err);

    // Another request refreshed while this one was in flight: the new token is already here.
    final tokenChanged = _store.accessToken != null && _store.accessToken != options.extra[_sentToken];
    if (!tokenChanged && await _refresher.refresh() != RefreshOutcome.refreshed) {
      return handler.next(err);
    }

    try {
      options.extra[_retried] = true;
      _authorize(options);
      handler.resolve(await _retryClient.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  void _authorize(RequestOptions options) {
    final token = _store.accessToken;
    options.extra[_sentToken] = token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }
  }
}
