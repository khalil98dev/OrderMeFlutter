import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchProducts extends Mock implements WatchProducts {}

Product _product(String id, {num? price = 1200}) => Product(
  id: id,
  clientId: 'c1',
  name: 'Livre $id',
  type: ProductType.guide,
  isAvailable: true,
  hasImage: false,
  createdAt: DateTime(2026, 11, 4),
  price: price,
);

PagedList<Product> _page(int page, List<String> ids, {required int total}) =>
    PagedList(items: [for (final id in ids) _product(id)], page: page, pageSize: 2, totalCount: total);

void main() {
  setUpAll(() => registerFallbackValue(const WatchProductsParams(ProductQuery())));

  group('ProductModel', () {
    test('reads the API shape; a hidden price stays null, not 0', () {
      final product = ProductModel.fromJson({
        'id': 'p1',
        'clientId': 'c1',
        'clientName': 'Amina Benali',
        'name': 'Maths 3AS',
        'code': 'MATH-3AS',
        'type': 'PracticeBook',
        'pageCount': 120,
        'price': null,
        'isAvailable': false,
        'hasImage': true,
        'createdAt': '2026-11-04T10:00:00+00:00',
      });

      expect(product.type, ProductType.practiceBook);
      expect(product.price, isNull);
      expect(product.isAvailable, isFalse);
    });

    test('an unknown type from a newer server reads as "other"', () {
      expect(ProductType.fromApi('Poster'), ProductType.other);
    });
  });

  group('ProductQuery', () {
    test('leaves empty filters out of the request', () {
      expect(const ProductQuery().toQueryParameters(), {'page': 1, 'pageSize': 20});
    });

    test('a new search starts again from page 1', () {
      final query = const ProductQuery().nextPage().nextPage().withSearch('bac');
      expect(query.page, 1);
      expect(query.search, 'bac');
    });

    test('cache keys differ per filter and all start with "products"', () {
      const all = ProductQuery();
      final available = all.withAvailability(true);
      expect(all.cacheKey, isNot(available.cacheKey));
      expect(available.cacheKey, startsWith('products'));
    });
  });

  group('ProductsCubit', () {
    late _MockWatchProducts watch;

    setUp(() => watch = _MockWatchProducts());

    test('shows the cached page, then the fresh one', () async {
      when(() => watch(any())).thenAnswer(
        (_) => Stream.fromIterable([
          Result.ok(_page(1, ['old'], total: 1)),
          Result.ok(_page(1, ['new'], total: 1)),
        ]),
      );
      final cubit = ProductsCubit(watch);
      final shown = <List<String>>[];
      final subscription = cubit.stream.listen((s) => shown.add([for (final p in s.products) p.id]));

      await cubit.load();
      await subscription.cancel();

      expect(
        shown,
        containsAllInOrder([
          ['old'],
          ['new'],
        ]),
      );
      expect(cubit.state.isLoading, isFalse);
    });

    test('loadMore appends the next page and stops when everything is loaded', () async {
      when(() => watch(any())).thenAnswer((invocation) {
        final params = invocation.positionalArguments.first as WatchProductsParams;
        final page = params.query.page == 1 ? _page(1, ['a', 'b'], total: 3) : _page(2, ['c'], total: 3);
        return Stream.value(Result.ok(page));
      });
      final cubit = ProductsCubit(watch);

      await cubit.load();
      expect(cubit.state.hasMore, isTrue);
      await cubit.loadMore();

      expect([for (final p in cubit.state.products) p.id], ['a', 'b', 'c']);
      expect(cubit.state.hasMore, isFalse);

      await cubit.loadMore(); // nothing left: no request
      verify(() => watch(any())).called(2);
    });

    test('a failure keeps the products already shown', () async {
      var call = 0;
      when(() => watch(any())).thenAnswer(
        (_) => Stream.value(
          call++ == 0 ? Result.ok(_page(1, ['a'], total: 1)) : const Result.err(NetworkFailure()),
        ),
      );
      final cubit = ProductsCubit(watch);

      await cubit.load();
      await cubit.load(refresh: true);

      expect(cubit.state.failure, const NetworkFailure());
      expect(cubit.state.products, hasLength(1));
    });
  });
}
