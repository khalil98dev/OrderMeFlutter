import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/failure.dart';
import '../result/result.dart';
import 'auth_interceptor.dart';
import 'failure_mapper.dart';
import 'token_refresher.dart';
import 'token_store.dart';

/// Turns JSON (already decoded by Dio) into a model.
typedef JsonDecoder<T> = T Function(Object? json);

/// The one way the data layer talks to the API. Every call returns a [Result]; nothing throws.
///
/// JSON is decoded by Dio's `BackgroundTransformer`, which moves large bodies (> 50 KB) to a
/// background isolate, so a long list never blocks a frame.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Request options for calls that must not carry or refresh a token (login, refresh, logout).
  static final Options anonymous = Options(extra: {AuthInterceptor.skipAuth: true});

  Future<Result<T>> get<T>(
    String path, {
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.get<Object?>(path, queryParameters: query, options: options, cancelToken: cancelToken),
    decode,
  );

  Future<Result<T>> post<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(() => _dio.post<Object?>(path, data: data, options: options, cancelToken: cancelToken), decode);

  Future<Result<T>> put<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) => _send(() => _dio.put<Object?>(path, data: data, options: options, cancelToken: cancelToken), decode);

  Future<Result<T>> delete<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _send(() => _dio.delete<Object?>(path, data: data, options: options, cancelToken: cancelToken), decode);

  /// For answers with no body (204).
  static void ignoreBody(Object? _) {}

  /// Keeps the decoded JSON as is, for callers that cache the raw answer.
  static Object? rawJson(Object? json) => json;

  Future<Result<T>> _send<T>(Future<Response<Object?>> Function() call, JsonDecoder<T> decode) async {
    try {
      final response = await call();
      return Result.ok(decode(response.data));
    } on DioException catch (e) {
      return Result.err(FailureMapper.fromDio(e));
    } on Object catch (e) {
      // A model could not read the answer: the API and the app disagree on a shape.
      return Result.err(UnexpectedFailure('Could not read the server answer.', e));
    }
  }
}

/// Builds the app's Dio: base URL, API version header, timeouts, background JSON, and auth.
Dio createApiDio({required AppConfig config, required TokenStore store, required TokenRefresher refresher}) {
  final dio = Dio(baseOptions(config))..transformer = BackgroundTransformer();
  dio.interceptors.add(AuthInterceptor(store: store, refresher: refresher, retryClient: dio));
  return dio;
}

/// Shared by the API client and the bare client used for token refresh.
BaseOptions baseOptions(AppConfig config) => BaseOptions(
  baseUrl: config.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  sendTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  headers: const {'X-Api-Version': '1', 'Accept': 'application/json'},
);

/// Debug builds only: accepts the dev backend's self-signed certificate for its own host and port.
///
/// Installed as [HttpOverrides.global], so it covers every `HttpClient` in the app: Dio and the SignalR
/// hub (its negotiate request and its WebSocket) alike. Any other host is still checked normally.
void trustDevCertificate(AppConfig config) {
  if (!kDebugMode || kIsWeb) return;
  final uri = Uri.parse(config.apiBaseUrl);
  if (uri.scheme != 'https') return;
  HttpOverrides.global = _DevCertificateOverrides(uri.host, uri.port);
}

final class _DevCertificateOverrides extends HttpOverrides {
  _DevCertificateOverrides(this._host, this._port);

  final String _host;
  final int _port;

  @override
  HttpClient createHttpClient(SecurityContext? context) => super.createHttpClient(context)
    ..badCertificateCallback = (cert, host, port) => host == _host && port == _port;
}
