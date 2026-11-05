import 'package:flutter/widgets.dart';
import 'package:medstore_core/medstore_core.dart';

import 'app_error_state.dart';
import 'app_skeleton.dart';

/// Chooses what a loading screen shows, in one place, so every screen behaves the same:
///
/// 1. **Data, if there is any** — even while refreshing or after a failed refresh. With the hybrid
///    cache this means cached data stays on screen offline instead of being replaced by an error.
/// 2. Otherwise **loading** → a skeleton.
/// 3. Otherwise **failure** → an error with "Try again".
/// 4. Otherwise **empty** → [empty].
///
/// ```dart
/// AppLoadView(
///   isLoading: state.isLoading,
///   failure: state.failure,
///   hasData: state.orders.isNotEmpty,
///   onRetry: cubit.load,
///   empty: AppEmptyState(icon: CupertinoIcons.cart, title: strings.noOrders),
///   builder: (context) => OrdersList(state.orders),
/// )
/// ```
class AppLoadView extends StatelessWidget {
  const AppLoadView({
    super.key,
    required this.isLoading,
    required this.hasData,
    required this.builder,
    required this.empty,
    this.failure,
    this.onRetry,
    this.loading = const AppSkeletonList(),
  });

  final bool isLoading;
  final bool hasData;
  final Failure? failure;

  /// Builds the content. Only called when there is data, so it never has to handle the other cases.
  final WidgetBuilder builder;
  final Widget empty;
  final VoidCallback? onRetry;

  /// Defaults to a list-shaped skeleton; pass one shaped like your content (a grid, a form).
  final Widget loading;

  @override
  Widget build(BuildContext context) {
    if (hasData) {
      return builder(context);
    }
    if (isLoading) {
      return loading;
    }
    final failure = this.failure;
    if (failure != null && failure is! CancelledFailure) {
      return AppErrorState(failure: failure, onRetry: onRetry);
    }
    return empty;
  }
}
