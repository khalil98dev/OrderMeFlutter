import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/pagination/paged_list.dart';
import '../../../core/result/result.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_query.dart';
import '../domain/usecases/product_usecases.dart';

final class ProductsState extends Equatable {
  const ProductsState({
    this.query = const ProductQuery(),
    this.products = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final ProductQuery query;

  /// Every product loaded so far (all pages), in the API's order.
  final List<Product> products;
  final int totalCount;
  final bool hasMore;

  /// The first page is loading (the list may still show older, cached products).
  final bool isLoading;
  final bool isLoadingMore;

  /// The last load failed. Products already shown stay on screen.
  final Failure? failure;

  ProductsState loading() => _with(isLoading: true, failure: null);

  ProductsState withQuery(ProductQuery value) => ProductsState(query: value, isLoading: true);

  ProductsState withFirstPage(PagedList<Product> page) => _with(
    products: page.items,
    totalCount: page.totalCount,
    hasMore: page.hasMore,
    isLoading: false,
    failure: null,
  );

  ProductsState loadingMore() => _with(isLoadingMore: true, failure: null);

  ProductsState withNextPage(PagedList<Product> page) => _with(
    products: [...products, ...page.items],
    totalCount: page.totalCount,
    hasMore: page.hasMore,
    isLoadingMore: false,
    failure: null,
  );

  ProductsState failed(Failure value) => _with(isLoading: false, isLoadingMore: false, failure: value);

  ProductsState _with({
    List<Product>? products,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    required Failure? failure,
  }) => ProductsState(
    query: query,
    products: products ?? this.products,
    totalCount: totalCount ?? this.totalCount,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [query, products, totalCount, hasMore, isLoading, isLoadingMore, failure];
}

/// A searchable, filterable, endlessly scrolling list of products. Both apps use it.
///
/// The first page comes from the cache at once (if any), then from the API. Further pages load when
/// the user scrolls near the end ([loadMore]).
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._watchProducts) : super(const ProductsState());

  final WatchProducts _watchProducts;
  StreamSubscription<Result<PagedList<Product>>>? _firstPage;
  Completer<void>? _firstPageDone;

  /// The query of the last page shown; [loadMore] asks for the one after it.
  ProductQuery? _lastLoadedPage;

  /// Loads the first page. Pull to refresh passes [refresh] to skip the cache; the returned future
  /// completes when the fresh answer arrived, so the refresh spinner can wait for it.
  Future<void> load({bool refresh = false}) async {
    await _stopFirstPage();
    emit(state.loading());

    final done = Completer<void>();
    _firstPageDone = done;
    _firstPage = _watchProducts(WatchProductsParams(state.query, refresh: refresh)).listen(
      (result) {
        switch (result) {
          case Ok(:final value):
            _lastLoadedPage = state.query;
            emit(state.withFirstPage(value));
          case Err(:final failure):
            emit(state.failed(failure));
        }
      },
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  Future<void> search(String text) async {
    if (text == state.query.search) return;
    emit(state.withQuery(state.query.withSearch(text)));
    await load();
  }

  /// Null shows both available and unavailable products.
  Future<void> showAvailability(bool? isAvailable) async {
    emit(state.withQuery(state.query.withAvailability(isAvailable)));
    await load();
  }

  /// Null shows every type.
  Future<void> showType(ProductType? type) async {
    emit(state.withQuery(state.query.withType(type)));
    await load();
  }

  /// Null shows every teacher's products (admin app).
  Future<void> showTeacher(String? clientId) async {
    emit(state.withQuery(state.query.withClient(clientId)));
    await load();
  }

  Future<void> loadMore() async {
    final lastLoaded = _lastLoadedPage;
    if (lastLoaded == null || !state.hasMore || state.isLoading || state.isLoadingMore) return;

    final query = state.query;
    final nextPage = lastLoaded.nextPage();
    emit(state.loadingMore());

    final result = await _watchProducts(WatchProductsParams(nextPage)).last;
    if (isClosed || state.query != query) return; // the search changed while this page was loading

    switch (result) {
      case Ok(:final value):
        _lastLoadedPage = nextPage;
        emit(state.withNextPage(value));
      case Err(:final failure):
        emit(state.failed(failure));
    }
  }

  Future<void> _stopFirstPage() async {
    await _firstPage?.cancel();
    final done = _firstPageDone;
    if (done != null && !done.isCompleted) done.complete();
  }

  @override
  Future<void> close() async {
    await _stopFirstPage();
    return super.close();
  }
}
