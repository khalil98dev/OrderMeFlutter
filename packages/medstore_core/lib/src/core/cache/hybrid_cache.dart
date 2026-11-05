import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;

import '../error/failure.dart';
import '../result/result.dart';
import 'cache_store.dart';

/// Two-level cache: [memory] (instant) in front of [disk] (survives restarts).
///
/// Keys are prefixed with the signed-in user's id ([useScope]), so one user's cached rows can never be
/// shown to another; the whole cache is wiped on sign-out ([clear]). This mirrors the API's own
/// `CachingBehavior`, which keys on the caller.
class HybridCache {
  HybridCache({required this.memory, required this.disk, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// JSON longer than this is decoded on a background isolate (`compute`) instead of the UI thread.
  static const backgroundDecodeThreshold = 50 * 1024;

  final CacheStore memory;
  final CacheStore disk;
  final DateTime Function() _clock;
  String _scope = 'anonymous';

  void useScope(String userId) => _scope = userId;

  String _key(String key) => '$_scope:$key';

  Future<CacheEntry?> read(String key) async {
    final scoped = _key(key);
    final hot = await memory.read(scoped);
    if (hot != null) return hot;
    final cold = await disk.read(scoped);
    if (cold != null) await memory.write(scoped, cold);
    return cold;
  }

  Future<void> write(String key, String json) async {
    final entry = CacheEntry(json, _clock());
    final scoped = _key(key);
    await memory.write(scoped, entry);
    await disk.write(scoped, entry);
  }

  /// Forget one answer, or every answer under a prefix (`invalidate('orders')` after creating an order).
  Future<void> invalidate(String keyOrPrefix) async {
    final scoped = _key(keyOrPrefix);
    await memory.removePrefix(scoped);
    await disk.removePrefix(scoped);
  }

  Future<void> clear() async {
    await memory.clear();
    await disk.clear();
  }

  /// Stale-while-revalidate:
  ///
  /// 1. A cached answer is emitted at once (the screen shows data without waiting).
  /// 2. If it is younger than [maxAge], that is all.
  /// 3. Otherwise [fetch] runs; a success is cached and emitted.
  /// 4. A failure is emitted **only when nothing was shown**: offline with cached data, the screen keeps
  ///    the cached data instead of turning into an error.
  ///
  /// [fetch] returns the raw decoded JSON (use `ApiClient.rawJson`); [decode] builds the model from it,
  /// for both the cached and the fresh answer. [forceRefresh] skips step 1-2 (pull to refresh).
  Stream<Result<T>> fetch<T>({
    required String key,
    required Duration maxAge,
    required Future<Result<Object?>> Function() fetch,
    required T Function(Object? json) decode,
    bool forceRefresh = false,
  }) async* {
    var shown = false;
    final cached = await read(key);

    if (cached != null && !forceRefresh) {
      try {
        yield Result.ok(decode(await _decodeJson(cached.json)));
        shown = true;
        if (cached.isFresh(maxAge, _clock())) return;
      } on Object {
        // Written by an older app version with another shape: drop it and fetch.
        await memory.remove(_key(key));
        await disk.remove(_key(key));
      }
    }

    switch (await fetch()) {
      case Ok(:final value):
        final T model;
        try {
          model = decode(value);
        } on Object catch (e) {
          if (!shown) yield Result.err(UnexpectedFailure('Could not read the server answer.', e));
          return;
        }
        await write(key, jsonEncode(value));
        yield Result.ok(model);
      case Err(:final failure):
        if (!shown) yield Result.err(failure);
    }
  }

  static Future<Object?> _decodeJson(String json) => json.length > backgroundDecodeThreshold
      ? compute(jsonDecode, json) // background isolate on mobile/desktop; inline on the web
      : Future.value(jsonDecode(json));
}
