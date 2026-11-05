import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../pagination/paged_list.dart';
import '../result/result.dart';

/// Loads page [page] of the list matching [filter]. Usually a use case: `(f, page) => listOrders(f, page)`.
typedef PageLoader<T, F> = Future<Result<PagedList<T>>> Function(F filter, int page);

final class PagedListState<T, F> extends Equatable {
  const PagedListState({
    required this.filter,
    this.items = const [],
    this.totalCount = 0,
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
  });

  /// What is listed: search text, status, teacher, period…
  final F filter;

  /// Every item loaded so far (all pages), in the API's order.
  final List<T> items;
  final int totalCount;

  /// The last page loaded (0 before the first answer).
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  /// The last load failed. Items already shown stay.
  final Failure? failure;

  PagedListState<T, F> copyWith({
    F? filter,
    List<T>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    required Failure? failure,
  }) => PagedListState(
    filter: filter ?? this.filter,
    items: items ?? this.items,
    totalCount: totalCount ?? this.totalCount,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [filter, items, totalCount, page, hasMore, isLoading, isLoadingMore, failure];
}

/// Any filtered, endlessly scrolling list of the API (`PagedResult`): orders, invoices, wallets, debts…
///
/// ```dart
/// BlocProvider(create: (_) => PagedListCubit<OrderSummary, OrderFilter>(
///   (filter, page) => listOrders(ListOrdersParams(filter, page: page)),
///   filter: const OrderFilter(),
/// )..load())
/// ```
///
/// Changing the filter starts again from page 1; an answer to an older filter is dropped, so fast typing
/// never shows the results of an earlier search.
class PagedListCubit<T, F> extends Cubit<PagedListState<T, F>> {
  PagedListCubit(this._load, {required F filter}) : super(PagedListState(filter: filter));

  final PageLoader<T, F> _load;

  /// Bumped by every first-page load, so late answers to an older one are ignored.
  int _generation = 0;

  /// Loads the first page again (also "refresh" after a change). Items stay on screen while loading.
  Future<void> load() async {
    final generation = ++_generation;
    emit(state.copyWith(isLoading: true, isLoadingMore: false, failure: null));
    final result = await _load(state.filter, 1);
    if (isClosed || generation != _generation) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        items: value.items,
        totalCount: value.totalCount,
        page: 1,
        hasMore: value.hasMore,
        isLoading: false,
        failure: null,
      ),
      Err(:final failure) => state.copyWith(isLoading: false, failure: failure),
    });
  }

  /// Shows [filter]'s list from its first page. The old items are cleared: they no longer match.
  Future<void> setFilter(F filter) async {
    if (filter == state.filter && state.page > 0) return;
    emit(PagedListState(filter: filter));
    await load();
  }

  /// Loads the next page; ignored while anything is loading or when there is no next page.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    final generation = _generation;
    final next = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, failure: null));
    final result = await _load(state.filter, next);
    if (isClosed || generation != _generation) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        items: [...state.items, ...value.items],
        totalCount: value.totalCount,
        page: next,
        hasMore: value.hasMore,
        isLoadingMore: false,
        failure: null,
      ),
      Err(:final failure) => state.copyWith(isLoadingMore: false, failure: failure),
    });
  }
}
