import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../domain/admin_orders.dart';

/// One order: its lines, its timeline, and the moves the team may make (prepare, ready, delivered,
/// cancel) or a revision of its lines.
///
/// Expects a `LoadCubit<Order>` and [ChangeOrderStatus] above it.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Order>>();
    final state = context.watch<LoadCubit<Order>>().state;
    final order = state.data;

    return AdminPage(
      title: order == null ? strings.navOrders : strings.orderNumber(order.number),
      subtitle: order?.clientName,
      onBack: () => context.pop(),
      actions: [
        if (order != null) ...[
          if (order.status.staffCanRevise)
            AppButton(
              label: strings.reviseOrder,
              icon: CupertinoIcons.pencil,
              variant: AppButtonVariant.plain,
              onPressed: () => _revise(context, order),
            ),
          for (final status in order.status.staffMoves)
            AppButton(
              label: orderMoveText(strings, status),
              variant: status == OrderStatus.cancelled
                  ? AppButtonVariant.destructive
                  : AppButtonVariant.filled,
              onPressed: () => _move(context, order, status),
            ),
        ],
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: order != null,
        failure: state.failure,
        onRetry: cubit.load,
        empty: const SizedBox.shrink(),
        builder: (context) => _OrderBody(order: order!),
      ),
    );
  }

  static Future<void> _revise(BuildContext context, Order order) async {
    final cubit = context.read<LoadCubit<Order>>();
    final message = await context.push<String>('/orders/${order.id}/edit', extra: order);
    if (!context.mounted || message == null) return;
    showAppToast(context, message, tone: AppTone.success);
    await cubit.load();
  }

  /// Asks for a note (required to cancel once preparation started), then moves the order.
  static Future<void> _move(BuildContext context, Order order, OrderStatus status) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Order>>();
    final changeStatus = context.read<ChangeOrderStatus>();
    final cancelling = status == OrderStatus.cancelled;

    final note = await showAppTextPrompt(
      context,
      title: strings.changeStatusTitle(orderStatusText(strings, status)),
      message: cancelling ? strings.cancelOrderMessage : null,
      label: strings.statusNoteLabel,
      confirmLabel: orderMoveText(strings, status),
      isRequired: cancelling && order.status.cancelNeedsNote,
      destructive: cancelling,
    );
    if (note == null || !context.mounted) return;

    final result = await changeStatus(ChangeOrderStatusParams(order.id, status, note: note));
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.orderStatusChanged, tone: AppTone.success);
        await cubit.load();
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
        await cubit.load(); // a 409 means it changed meanwhile: show the current state
    }
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final notes = order.notes;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      AppInfoRow(
                        label: strings.colStatus,
                        child: AppBadge(
                          label: orderStatusText(strings, order.status),
                          tone: orderStatusTone(order.status),
                        ),
                      ),
                      AppInfoRow(
                        label: strings.colDate,
                        value: AppDateFormat.dateTime(order.placedAt, locale),
                      ),
                      AppInfoRow(label: strings.colTeacher, value: order.clientName),
                      if (notes != null) AppInfoRow(label: strings.fieldNotes, value: notes),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppFieldLabel(strings.orderLines),
                AppTable(
                  shrinkWrap: true,
                  columns: [
                    AppTableColumn(strings.colProduct, flex: 3),
                    AppTableColumn(strings.fieldCode, width: 120),
                    AppTableColumn.amount(strings.colUnitPrice),
                    AppTableColumn(strings.colQuantity, width: 70),
                    AppTableColumn.amount(strings.colTotal),
                  ],
                  rowCount: order.lines.length,
                  cells: (context, index) {
                    final line = order.lines[index];
                    return [
                      Text(line.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(line.productCode ?? '—'),
                      AppMoney(line.unitPrice, style: AppTypography.subheadline),
                      Text('${line.quantity}'),
                      AppMoney(line.lineTotal, style: AppTypography.subheadline),
                    ];
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    width: 320,
                    child: AppInfoRow(
                      label: strings.total,
                      emphasized: true,
                      child: AppMoney(order.total, style: AppTypography.headline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 2,
            child: AppSection(
              header: strings.orderHistory,
              children: [
                for (final step in order.history)
                  AppListTile(
                    leading: AppBadge(
                      label: orderStatusText(strings, step.status),
                      tone: orderStatusTone(step.status),
                    ),
                    title: AppDateFormat.dateTime(step.changedAt, locale),
                    subtitle: [
                      step.changedByName == null
                          ? actorText(strings, step.actor)
                          : strings.byName(step.changedByName!),
                      ?step.note,
                    ].join(' · '),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
