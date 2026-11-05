import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_core/src/core/network/api_client.dart';
import 'package:medstore_core/src/core/network/token_pair.dart';
import 'package:medstore_core/src/core/network/token_refresher.dart';
import 'package:medstore_core/src/core/network/token_store.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body, Future<void>? cancel) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

Map<String, Object?> _pair(String access, String refresh, DateTime now) => {
  'accessToken': access,
  'accessTokenExpiresAt': now.add(const Duration(minutes: 15)).toIso8601String(),
  'refreshToken': refresh,
  'refreshTokenExpiresAt': now.add(const Duration(days: 30)).toIso8601String(),
};

void main() {
  const config = AppConfig(apiBaseUrl: 'http://api.test');
  final now = DateTime(2026, 11, 4, 12);

  late TokenStore store;
  late TokenRefresher refresher;
  late ApiClient api;
  late int refreshCalls;
  late int Function(String? refreshToken) refreshStatus;
  late List<String?> sentTokens;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = TokenStore(const FlutterSecureStorage(), clock: () => now);
    await store.save(TokenPair.fromJson(_pair('old', 'r1', now)));

    refreshCalls = 0;
    refreshStatus = (_) => 200;
    sentTokens = [];

    final bare = Dio(BaseOptions(baseUrl: config.apiBaseUrl))
      ..httpClientAdapter = _FakeAdapter((options) async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 20)); // let other requests pile up
        final sent = (options.data as Map<String, Object?>)['refreshToken'] as String?;
        final status = refreshStatus(sent);
        return status == 200 ? _json(200, _pair('new', 'r2', now)) : _json(status, {'title': 'Unauthorized'});
      });
    refresher = TokenRefresher(dio: bare, store: store);

    final dio = createApiDio(config: config, store: store, refresher: refresher)
      ..httpClientAdapter = _FakeAdapter((options) async {
        final auth = options.headers['Authorization'] as String?;
        sentTokens.add(auth);
        return auth == 'Bearer new' ? _json(200, {'ok': true}) : _json(401, {'title': 'Unauthorized'});
      });
    api = ApiClient(dio);
  });

  Future<Result<Object?>> getOrders() => api.get('/api/orders', decode: ApiClient.rawJson);

  test('parallel 401s share one refresh, then every request is retried and succeeds', () async {
    final results = await Future.wait([getOrders(), getOrders(), getOrders()]);

    expect(results.every((r) => r.isOk), isTrue);
    expect(refreshCalls, 1, reason: 'refresh tokens are single use: never refresh twice at once');
    expect(store.accessToken, 'new');
    expect(await store.readRefreshToken(), 'r2');
  });

  test('a refused refresh ends the session: Unauthorized, tokens cleared, sessionExpired fired', () async {
    refreshStatus = (_) => 401;
    final expired = expectLater(refresher.sessionExpired, emits(null));

    final result = await getOrders();

    expect(result.fold((f) => f, (_) => null), isA<UnauthorizedFailure>());
    expect(store.accessToken, isNull);
    expect(await store.readRefreshToken(), isNull);
    await expired;
  });

  test('an access token about to expire is refreshed before the request, so no 401 happens', () async {
    await store.save(
      TokenPair(
        accessToken: 'old',
        accessTokenExpiresAt: now.add(const Duration(seconds: 10)),
        refreshToken: 'r1',
        refreshTokenExpiresAt: now.add(const Duration(days: 30)),
      ),
    );

    final result = await getOrders();

    expect(result.isOk, isTrue);
    expect(refreshCalls, 1);
    expect(sentTokens, ['Bearer new']);
  });

  test('an unreachable server keeps the session', () async {
    refreshStatus = (_) => 503;

    final result = await getOrders();

    expect(result.isOk, isFalse);
    expect(await store.readRefreshToken(), 'r1');
  });
}
