import 'package:hive_ce/hive_ce.dart';

import 'cache_store.dart';

/// Cache on disk in a hive_ce box. Survives restarts, so the app opens with data even offline.
///
/// Each value is a small map `{t: savedAt millis, d: json}`: plain types, so no adapters or code
/// generation. `Hive.init(path)` must run before first use (each app's DI does it).
class HiveCacheStore implements CacheStore {
  HiveCacheStore({this.boxName = 'medstore_cache'});

  final String boxName;
  Future<Box<Map<dynamic, dynamic>>>? _box;

  // Opened on first use, so start-up does not wait for the disk.
  Future<Box<Map<dynamic, dynamic>>> get _opened => _box ??= Hive.openBox<Map<dynamic, dynamic>>(boxName);

  @override
  Future<CacheEntry?> read(String key) async {
    final value = (await _opened).get(key);
    if (value == null) return null;
    final savedAt = value['t'];
    final json = value['d'];
    if (savedAt is! int || json is! String) return null;
    return CacheEntry(json, DateTime.fromMillisecondsSinceEpoch(savedAt));
  }

  @override
  Future<void> write(String key, CacheEntry entry) async =>
      (await _opened).put(key, {'t': entry.savedAt.millisecondsSinceEpoch, 'd': entry.json});

  @override
  Future<void> remove(String key) async => (await _opened).delete(key);

  @override
  Future<void> removePrefix(String prefix) async {
    final box = await _opened;
    await box.deleteAll(box.keys.where((key) => key is String && key.startsWith(prefix)));
  }

  @override
  Future<void> clear() async => (await _opened).clear();
}
