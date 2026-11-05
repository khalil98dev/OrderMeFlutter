/// One cached API answer: its JSON text and when it was saved.
final class CacheEntry {
  const CacheEntry(this.json, this.savedAt);

  final String json;
  final DateTime savedAt;

  bool isFresh(Duration maxAge, DateTime now) => now.difference(savedAt) < maxAge;
}

/// A place to keep [CacheEntry]s by key. Implemented in memory and on disk.
abstract interface class CacheStore {
  Future<CacheEntry?> read(String key);

  Future<void> write(String key, CacheEntry entry);

  Future<void> remove(String key);

  /// Removes every key that starts with [prefix] (for example everything about orders).
  Future<void> removePrefix(String prefix);

  Future<void> clear();
}
