import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_core/src/core/cache/memory_cache_store.dart';

void main() {
  late DateTime now;
  late MemoryCacheStore memory;
  late MemoryCacheStore disk;
  late HybridCache cache;
  late int fetches;

  setUp(() {
    now = DateTime(2026, 11, 4, 12);
    memory = MemoryCacheStore();
    disk = MemoryCacheStore();
    cache = HybridCache(memory: memory, disk: disk, clock: () => now)..useScope('user-1');
    fetches = 0;
  });

  Stream<Result<List<String>>> products({Result<Object?>? answer, bool force = false}) => cache.fetch(
    key: 'products',
    maxAge: const Duration(minutes: 5),
    forceRefresh: force,
    fetch: () async {
      fetches++;
      return answer ??
          const Result.ok([
            {'name': 'Book A'},
          ]);
    },
    decode: (json) => [
      for (final item in json! as List<Object?>) (item! as Map<String, Object?>)['name']! as String,
    ],
  );

  List<Object?> values(List<Result<List<String>>> results) => [
    for (final r in results) r.fold((f) => f, (v) => v),
  ];

  test('first load fetches, emits once, and writes both levels', () async {
    expect(values(await products().toList()), [
      ['Book A'],
    ]);
    expect(fetches, 1);
    expect(await memory.read('user-1:products'), isNotNull);
    expect(await disk.read('user-1:products'), isNotNull);
  });

  test('a fresh cached answer is emitted without a network call', () async {
    await products().drain<void>();
    now = now.add(const Duration(minutes: 1));

    expect(values(await products().toList()), [
      ['Book A'],
    ]);
    expect(fetches, 1);
  });

  test('a stale answer is shown at once, then replaced by the fresh one', () async {
    await products().drain<void>();
    now = now.add(const Duration(minutes: 10));

    final results = await products(
      answer: const Result.ok([
        {'name': 'Book B'},
      ]),
    ).toList();

    expect(values(results), [
      ['Book A'],
      ['Book B'],
    ]);
  });

  test('offline with cached data: no error replaces what is shown', () async {
    await products().drain<void>();
    now = now.add(const Duration(minutes: 10));

    final results = await products(answer: const Result.err(NetworkFailure())).toList();

    expect(values(results), [
      ['Book A'],
    ]);
  });

  test('offline with nothing cached: the failure is emitted', () async {
    final results = await products(answer: const Result.err(NetworkFailure())).toList();
    expect(values(results), [const NetworkFailure()]);
  });

  test('after a restart the disk answer is used and promoted to memory', () async {
    await products().drain<void>();
    await memory.clear(); // the app restarted

    await products().drain<void>();

    expect(fetches, 1);
    expect(await memory.read('user-1:products'), isNotNull);
  });

  test('another user never sees the first user\'s cache', () async {
    await products().drain<void>();
    cache.useScope('user-2');

    await products().drain<void>();

    expect(fetches, 2);
  });
}
