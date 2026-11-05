import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:medstore_core/medstore_core.dart';

/// One answer of the fake server.
final class FakeReply {
  const FakeReply(this.body, {this.status = 200});

  const FakeReply.noContent() : body = null, status = 204;

  final Object? body;
  final int status;
}

/// An [ApiClient] over a fake server: records every request and answers with [reply].
///
/// ```dart
/// final api = FakeApi()..reply = (request) => const FakeReply({'id': '1'});
/// await repository.get('1');
/// expect(api.last.path, '/api/admin/clients/1');
/// ```
class FakeApi {
  FakeApi() {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = _Adapter(this);
    client = ApiClient(dio);
  }

  late final ApiClient client;
  final requests = <RequestOptions>[];
  FakeReply Function(RequestOptions request) reply = (_) => const FakeReply.noContent();

  RequestOptions get last => requests.last;

  /// The JSON body of the last request.
  Object? get lastBody => last.data;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this._api);

  final FakeApi _api;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _api.requests.add(options);
    final reply = _api.reply(options);
    final body = reply.body;
    if (body is Uint8List) {
      return ResponseBody.fromBytes(
        body,
        reply.status,
        headers: {
          Headers.contentTypeHeader: ['application/pdf'],
        },
      );
    }
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [body == null ? 'text/plain' : 'application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A [CacheStore] in memory, for repositories that cache.
class MemoryStore implements CacheStore {
  final _entries = <String, CacheEntry>{};

  @override
  Future<CacheEntry?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, CacheEntry entry) async => _entries[key] = entry;

  @override
  Future<void> remove(String key) async => _entries.remove(key);

  @override
  Future<void> removePrefix(String prefix) async => _entries.removeWhere((key, _) => key.startsWith(prefix));

  @override
  Future<void> clear() async => _entries.clear();
}

/// A ProblemDetails body.
Map<String, Object?> problem(int status, {Map<String, List<String>> errors = const {}, String? title}) => {
  'status': status,
  'title': ?title,
  if (errors.isNotEmpty) 'errors': errors,
};

/// A `PagedResult` body.
Map<String, Object?> paged(List<Object?> items, {int page = 1, int pageSize = 50, int? total}) => {
  'items': items,
  'page': page,
  'pageSize': pageSize,
  'totalCount': total ?? items.length,
  'totalPages': 1,
};

T okValue<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('Expected Ok, got $failure'),
};

Failure errOf<T>(Result<T> result) => switch (result) {
  Ok() => throw StateError('Expected Err'),
  Err(:final failure) => failure,
};
