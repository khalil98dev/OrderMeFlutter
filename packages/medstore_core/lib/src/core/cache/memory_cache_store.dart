import 'cache_store.dart';

/// Least-recently-used cache in memory, bounded by [maxEntries] so it cannot grow without limit.
class MemoryCacheStore implements CacheStore {
  MemoryCacheStore({this.maxEntries = 200});

  final int maxEntries;

  // A map literal is a LinkedHashMap: it keeps insertion order, so re-inserting on read moves a key to
  // the "recent" end and the first key is always the least recently used.
  final _entries = <String, CacheEntry>{};

  @override
  Future<CacheEntry?> read(String key) async {
    final entry = _entries.remove(key);
    if (entry != null) _entries[key] = entry;
    return entry;
  }

  @override
  Future<void> write(String key, CacheEntry entry) async {
    _entries
      ..remove(key)
      ..[key] = entry;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  @override
  Future<void> remove(String key) async => _entries.remove(key);

  @override
  Future<void> removePrefix(String prefix) async => _entries.removeWhere((key, _) => key.startsWith(prefix));

  @override
  Future<void> clear() async => _entries.clear();
}
