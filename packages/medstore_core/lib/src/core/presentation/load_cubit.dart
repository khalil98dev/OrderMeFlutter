import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../result/result.dart';

final class LoadState<T> extends Equatable {
  const LoadState({this.data, this.isLoading = false, this.failure});

  /// The last value loaded. Stays while reloading and after a failed reload.
  final T? data;
  final bool isLoading;
  final Failure? failure;

  bool get hasData => data != null;

  @override
  List<Object?> get props => [data, isLoading, failure];
}

/// One thing loaded from the API for a screen: a detail (an order, an invoice), a report, the settings.
///
/// ```dart
/// BlocProvider(create: (_) => LoadCubit<Order>(() => getOrder(orderId))..load())
/// ```
///
/// Call [load] again after a change to show the new state; the old data stays on screen meanwhile.
/// For a screen whose source depends on inputs (a period), [loadWith] swaps the source and reloads.
class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit(this._source) : super(const LoadState());

  Future<Result<T>> Function() _source;
  int _generation = 0;

  Future<void> load() async {
    final generation = ++_generation;
    emit(LoadState(data: state.data, isLoading: true));
    final result = await _source();
    if (isClosed || generation != _generation) return;
    emit(switch (result) {
      Ok(:final value) => LoadState(data: value),
      Err(:final failure) => LoadState(data: state.data, failure: failure),
    });
  }

  /// Loads from a new source (the same report for another period).
  Future<void> loadWith(Future<Result<T>> Function() source) {
    _source = source;
    return load();
  }

  /// Shows a value the screen already has (the answer of a change), without asking the API again.
  void show(T value) => emit(LoadState(data: value));
}
