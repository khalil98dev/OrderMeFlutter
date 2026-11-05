import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failure.dart';
import '../result/result.dart';

enum SubmitStatus { idle, busy, done, failed }

final class SubmitState<T> extends Equatable {
  const SubmitState({this.status = SubmitStatus.idle, this.value, this.failure});

  final SubmitStatus status;

  /// The answer of the last successful action (the new deposit, the issued invoice).
  final T? value;
  final Failure? failure;

  bool get isBusy => status == SubmitStatus.busy;

  @override
  List<Object?> get props => [status, value, failure];
}

/// Runs one action at a time for a form or a button: a deposit, a status change, a void.
///
/// ```dart
/// final cubit = SubmitCubit<WalletTransaction>();
/// await cubit.run(() => recordDeposit(params));   // ignored while one is running (double click)
/// ```
///
/// Screens listen for [SubmitStatus.done] to close the dialog and for [SubmitStatus.failed] to show
/// the failure next to the form.
class SubmitCubit<T> extends Cubit<SubmitState<T>> {
  SubmitCubit() : super(SubmitState<T>());

  /// Returns the action's result, or null when it was ignored because another one is running.
  Future<Result<T>?> run(Future<Result<T>> Function() action) async {
    if (state.isBusy) return null;
    emit(SubmitState<T>(status: SubmitStatus.busy));
    final result = await action();
    if (isClosed) return result;
    emit(switch (result) {
      Ok(:final value) => SubmitState<T>(status: SubmitStatus.done, value: value),
      Err(:final failure) => SubmitState<T>(status: SubmitStatus.failed, failure: failure),
    });
    return result;
  }

  /// Back to idle (the user edits the form again after a failure).
  void reset() {
    if (!state.isBusy) emit(SubmitState<T>());
  }
}
