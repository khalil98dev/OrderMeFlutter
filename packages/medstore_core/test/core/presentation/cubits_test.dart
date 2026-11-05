import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';

PagedList<String> _page(int page, List<String> items, {int total = 4}) =>
    PagedList(items: items, page: page, pageSize: 2, totalCount: total);

void main() {
  group('PagedListCubit', () {
    test('loads the first page, then the next ones until there are no more', () async {
      final asked = <(String, int)>[];
      final cubit = PagedListCubit<String, String>((filter, page) async {
        asked.add((filter, page));
        return Result.ok(_page(page, ['$filter$page-a', '$filter$page-b']));
      }, filter: 'x');

      await cubit.load();
      await cubit.loadMore();
      await cubit.loadMore(); // page 2 of 2: nothing more to ask

      expect(cubit.state.items, ['x1-a', 'x1-b', 'x2-a', 'x2-b']);
      expect(cubit.state.hasMore, isFalse);
      expect(asked, [('x', 1), ('x', 2)]);
      await cubit.close();
    });

    test('a new filter starts again from page 1 and drops the answer to the old one', () async {
      final slow = Completer<Result<PagedList<String>>>();
      final cubit = PagedListCubit<String, String>(
        (filter, page) => filter == 'old' ? slow.future : Future.value(Result.ok(_page(1, ['new']))),
        filter: 'old',
      );

      final first = cubit.load();
      await cubit.setFilter('new');
      slow.complete(Result.ok(_page(1, ['old'])));
      await first;

      expect(cubit.state.filter, 'new');
      expect(cubit.state.items, ['new']);
      await cubit.close();
    });

    test('a failed load keeps the items already shown', () async {
      var fail = false;
      final cubit = PagedListCubit<String, String>(
        (filter, page) async => fail ? const Result.err(NetworkFailure()) : Result.ok(_page(1, ['a'])),
        filter: '',
      );
      await cubit.load();
      fail = true;
      await cubit.load();

      expect(cubit.state.items, ['a']);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.isLoading, isFalse);
      await cubit.close();
    });
  });

  group('LoadCubit', () {
    test('keeps the data while reloading and after a failed reload; loadWith swaps the source', () async {
      var answer = const Result<int>.ok(1);
      final cubit = LoadCubit<int>(() async => answer);
      await cubit.load();
      expect(cubit.state.data, 1);

      answer = const Result.err(ServerFailure());
      await cubit.load();
      expect(cubit.state.data, 1);
      expect(cubit.state.failure, isA<ServerFailure>());

      await cubit.loadWith(() async => const Result.ok(2));
      expect(cubit.state, const LoadState(data: 2));

      cubit.show(3);
      expect(cubit.state.data, 3);
      await cubit.close();
    });
  });

  group('SubmitCubit', () {
    test('runs one action at a time and reports done or failed', () async {
      final cubit = SubmitCubit<String>();
      final gate = Completer<Result<String>>();
      final first = cubit.run(() => gate.future);
      final second = await cubit.run(() async => const Result.ok('twice'));
      expect(second, isNull, reason: 'a double click is ignored');

      gate.complete(const Result.ok('saved'));
      await first;
      expect(cubit.state, const SubmitState<String>(status: SubmitStatus.done, value: 'saved'));

      await cubit.run(() async => const Result.err(ConflictFailure()));
      expect(cubit.state.status, SubmitStatus.failed);
      cubit.reset();
      expect(cubit.state.status, SubmitStatus.idle);
      await cubit.close();
    });
  });
}
