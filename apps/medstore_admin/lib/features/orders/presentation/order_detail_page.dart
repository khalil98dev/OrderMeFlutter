import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../domain/admin_orders.dart';
import 'order_changes.dart';

/// One order: its lines, its timeline, and the moves the team may make (prepare, ready, delivered,
/// cancel) or a revision of its lines.
///
/// Expects a `LoadCubit<Order>`, [ChangeOrderStatus] and [OrderChanges] above it; each change is
/// reported to [OrderChanges] so the orders list follows.
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
              icon: AppIcons.edit,
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
    final changes = context.read<OrderChanges>();
    final message = await context.push<String>('/orders/${order.id}/edit', extra: order);
    if (!context.mounted || message == null) return;
    showAppToast(context, message, tone: AppTone.success);
    changes.changed(order.id);
    await cubit.load();
  }

  /// Asks for a note (required to cancel once preparation started), then moves the order.
  static Future<void> _move(BuildContext context, Order order, OrderStatus status) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Order>>();
    final changeStatus = context.read<ChangeOrderStatus>();
    final changes = context.read<OrderChanges>();
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
        changes.changed(order.id); // the orders list shows the new status
        await cubit.load();
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
        changes.changed(order.id); // a 409 means it changed meanwhile: the list may be stale too
        await cubit.load(); // show the current state
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
    final copies = order.lines.fold<int>(0, (sum, line) => sum + line.quantity);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What was ordered comes first: each product and how many copies.
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: AppFieldLabel(strings.orderLines)),
                    Text(
                      '${strings.linesCount(order.lines.length)} · ${strings.copiesCount(copies)}',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.textSecondary.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final (index, line) in order.lines.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.xs),
                  _OrderLineCard(line: line),
                ],
                const SizedBox(height: AppSpacing.md),
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
                AppSection(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One line, read at a glance: the product's name in full and its quantity, large; the code, unit
/// price and line total quieter beside them.
class _OrderLineCard extends StatelessWidget {
  const _OrderLineCard({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final brand = AppColors.brand.resolveFrom(context);
    final secondary = AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.resolveFrom(context),
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        border: Border.all(color: AppColors.separator.resolveFrom(context), width: 0.5),
      ),
      child: Row(
        children: [
          // The quantity: the number the workshop prints from.
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.brandTint.resolveFrom(context),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Text(
                  '${line.quantity}',
                  style: AppTypography.tabular(
                    AppTypography.title2.copyWith(fontWeight: FontWeight.w700, height: 1.1, color: brand),
                  ),
                ),
                Text(
                  strings.colQuantity,
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: brand),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (line.productCode case final code?) ...[
                      Text(code, style: secondary),
                      Text('  ·  ', style: secondary),
                    ],
                    AppMoney(line.unitPrice, style: secondary),
                    Text(' × ${line.quantity}', style: secondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppMoney(line.lineTotal, style: AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
