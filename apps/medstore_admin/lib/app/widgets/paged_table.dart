import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// An [AppTable] fed by the [PagedListCubit] above it: loading, error and empty states, endless scroll.
///
/// ```dart
/// PagedTable<OrderSummary, OrderFilter>(
///   columns: [...],
///   cells: (context, order) => [...],
///   onTap: (order) => context.push('/orders/${order.id}'),
///   empty: AppEmptyState(icon: CupertinoIcons.cart, title: strings.noOrdersTitle),
/// )
/// ```
class PagedTable<T, F> extends StatelessWidget {
  const PagedTable({
    super.key,
    required this.columns,
    required this.cells,
    required this.empty,
    this.onTap,
    this.rowHeight = 56,
  });

  final List<AppTableColumn> columns;
  final List<Widget> Function(BuildContext context, T item) cells;
  final ValueChanged<T>? onTap;
  final Widget empty;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PagedListCubit<T, F>>();
    final state = context.watch<PagedListCubit<T, F>>().state;
    final onTap = this.onTap;

    return AppLoadView(
      isLoading: state.isLoading || state.page == 0,
      hasData: state.items.isNotEmpty,
      failure: state.failure,
      onRetry: cubit.load,
      empty: empty,
      builder: (context) => AppTable(
        columns: columns,
        rowCount: state.items.length,
        rowHeight: rowHeight,
        hasMore: state.hasMore,
        onEndReached: cubit.loadMore,
        onRowTap: onTap == null ? null : (index) => onTap(state.items[index]),
        cells: (context, index) => cells(context, state.items[index]),
      ),
    );
  }
}
