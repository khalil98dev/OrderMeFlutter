import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';
import '../surfaces/app_card.dart';
import '../surfaces/pressable.dart';

/// One column of an [AppTable]: its header text, its share of the width, and how its cells align.
final class AppTableColumn {
  const AppTableColumn(
    this.label, {
    this.flex = 1,
    this.width,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String label;

  /// Share of the free width. Ignored when [width] is set.
  final int flex;

  /// A fixed width in pixels (amounts, badges, buttons).
  final double? width;

  /// `centerEnd` for amounts, so the digits line up.
  final AlignmentDirectional alignment;

  /// A column for amounts: fixed width, aligned on the end side.
  const AppTableColumn.amount(this.label, {this.width = 130})
    : flex = 1,
      alignment = AlignmentDirectional.centerEnd;
}

/// A desktop table in a card: a header row, then one row per item, each cell under its column.
///
/// ```dart
/// AppTable(
///   columns: [
///     AppTableColumn(strings.colNumber, width: 90),
///     AppTableColumn(strings.colTeacher, flex: 2),
///     AppTableColumn.amount(strings.colTotal),
///   ],
///   rowCount: orders.length,
///   cells: (context, index) => [Text('#${orders[index].number}'), Text(orders[index].clientName), AppMoney(orders[index].total)],
///   onRowTap: (index) => open(orders[index]),
///   hasMore: state.hasMore,
///   onEndReached: cubit.loadMore,
/// )
/// ```
///
/// Rows are built lazily with a fixed height ([rowHeight]), so a list of thousands scrolls smoothly.
/// With [hasMore], a spinner row closes the list and [onEndReached] fires when the user nears it
/// (endless scroll). Inside another scroll view (a detail page), set [shrinkWrap]: every row is then
/// built at once, so keep that for short lists such as an order's lines.
class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cells,
    this.onRowTap,
    this.hasMore = false,
    this.onEndReached,
    this.rowHeight = 56,
    this.shrinkWrap = false,
  });

  final List<AppTableColumn> columns;
  final int rowCount;

  /// The cells of one row, one per column, in the columns' order.
  final List<Widget> Function(BuildContext context, int index) cells;
  final ValueChanged<int>? onRowTap;
  final bool hasMore;
  final VoidCallback? onEndReached;
  final double rowHeight;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final header = _Row(
      columns: columns,
      height: 36,
      children: [
        for (final column in columns)
          Text(
            column.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.footnote.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.resolveFrom(context),
            ),
          ),
      ],
    );

    Widget row(BuildContext context, int index) {
      if (index >= rowCount) {
        return SizedBox(
          height: rowHeight,
          child: const Center(child: CupertinoActivityIndicator()),
        );
      }
      final onRowTap = this.onRowTap;
      return Pressable(
        onTap: onRowTap == null ? null : () => onRowTap(index),
        child: _Row(columns: columns, height: rowHeight, divider: true, children: cells(context, index)),
      );
    }

    final count = rowCount + (hasMore ? 1 : 0);
    final Widget body = shrinkWrap
        ? Column(children: [for (var i = 0; i < count; i++) row(context, i)])
        : NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (hasMore && notification.metrics.extentAfter < rowHeight * 6) onEndReached?.call();
              return false;
            },
            child: ListView.builder(itemCount: count, itemExtent: rowHeight, itemBuilder: row),
          );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: 0.5, child: ColoredBox(color: AppColors.separator.resolveFrom(context))),
          if (shrinkWrap) body else Expanded(child: body),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.columns, required this.height, required this.children, this.divider = false});

  final List<AppTableColumn> columns;
  final double height;
  final List<Widget> children;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (final (index, column) in columns.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            _cell(column, index < children.length ? children[index] : const SizedBox.shrink()),
          ],
        ],
      ),
    );
    return Container(
      height: height,
      decoration: divider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.separator.resolveFrom(context), width: 0.5)),
            )
          : null,
      child: row,
    );
  }

  static Widget _cell(AppTableColumn column, Widget child) {
    final aligned = Align(alignment: column.alignment, child: child);
    final width = column.width;
    if (width != null) return SizedBox(width: width, child: aligned);
    return Expanded(flex: column.flex, child: aligned);
  }
}
