import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/widgets/order_status_tracker.dart';
import '../../../app/widgets/soft_card.dart';
import '../../notifications/domain/notification.dart';
import '../domain/my_orders.dart';
import 'orders_page.dart';

/// One order: where it is (the tracker), what the teacher can do now (cancel while pending, confirm
/// delivery once ready), its books, its total and its history.
///
/// Expects a `LoadCubit<Order>`, a `SubmitCubit<void>`, [CancelMyOrder] and [ConfirmDelivery] (the route)
/// and the app's [MyOrdersCubit] and [NotificationRepository] above it. A live notification about this order
/// reloads it.
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  StreamSubscription<TeacherNotification>? _live;

  @override
  void initState() {
    super.initState();
    final order = context.read<LoadCubit<Order>>();
    _live = context
        .read<NotificationRepository>()
        .arrivals
        .where((n) => n.link == 'orders/${widget.orderId}')
        .listen((_) => order.load());
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  Future<void> _act({
    required String title,
    required String message,
    required String confirm,
    required bool destructive,
    required Future<Result<void>> Function() action,
    required String done,
  }) async {
    final ok = await showAppConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirm,
      destructive: destructive,
    );
    if (!ok || !mounted) return;
    final order = context.read<LoadCubit<Order>>();
    final orders = context.read<MyOrdersCubit>();
    final result = await context.read<SubmitCubit<void>>().run(action);
    if (!mounted || result == null) return;
    if (result.isOk) {
      showAppToast(context, done, tone: AppTone.success);
      await order.load();
      unawaited(orders.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = context.watch<LoadCubit<Order>>().state;
    final order = state.data;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(order == null ? '' : strings.orderNumber(order.number)),
        previousPageTitle: strings.navOrders,
        border: null,
      ),
      child: SafeArea(
        child: AppLoadView(
          isLoading: state.isLoading,
          hasData: order != null,
          failure: state.failure,
          onRetry: context.read<LoadCubit<Order>>().load,
          loading: const Center(child: CupertinoActivityIndicator()),
          empty: const SizedBox.shrink(),
          builder: (context) {
            final cancel = context.read<CancelMyOrder>();
            final confirm = context.read<ConfirmDelivery>();
            return _OrderDetails(
              order: order!,
              onCancel: () => _act(
                title: strings.actionCancelOrder,
                message: strings.cancelMyOrderMessage,
                confirm: strings.actionCancelOrder,
                destructive: true,
                action: () => cancel(order.id),
                done: strings.orderCancelled,
              ),
              onConfirmDelivery: () => _act(
                title: strings.confirmDelivery,
                message: strings.confirmDeliveryMessage,
                confirm: strings.confirm,
                destructive: false,
                action: () => confirm(order.id),
                done: strings.deliveryConfirmed,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.order, required this.onCancel, required this.onConfirmDelivery});

  final Order order;
  final VoidCallback onCancel;
  final VoidCallback onConfirmDelivery;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final submit = context.watch<SubmitCubit<void>>().state;
    final primary = AppColors.textPrimary.resolveFrom(context);
    final secondary = AppColors.textSecondary.resolveFrom(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SoftCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppDateFormat.dateTime(order.placedAt.toLocal(), locale),
                      style: AppTypography.footnote.copyWith(color: secondary),
                    ),
                  ),
                  AppBadge(
                    label: orderStatusText(strings, order.status),
                    tone: orderStatusTone(order.status),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              OrderStatusTracker(status: order.status),
              if (order.status == OrderStatus.ready) ...[
                const SizedBox(height: AppSpacing.lg),
                AppMessage(text: strings.readyPickupHint, tone: AppTone.accent, icon: AppIcons.bag),
              ],
            ],
          ),
        ),
        if (submit.status == SubmitStatus.failed && submit.failure != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppMessage(text: failureText(strings, submit.failure!)),
        ],
        if (order.status == OrderStatus.ready) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: strings.confirmDelivery,
            icon: AppIcons.verified,
            expand: true,
            isLoading: submit.isBusy,
            onPressed: onConfirmDelivery,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Header(strings.orderLines),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (final (index, line) in order.lines.indexed) ...[
                if (index > 0) Container(height: 0.5, color: AppColors.separator.resolveFrom(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accentTint.resolveFrom(context),
                          borderRadius: AppRadii.smRadius,
                        ),
                        child: Text(
                          '×${line.quantity}',
                          style: AppTypography.tabular(
                            AppTypography.footnote.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent.resolveFrom(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.productName, style: AppTypography.subheadline.copyWith(color: primary)),
                            Text(
                              '${MoneyFormat.dzd(line.unitPrice, locale)} · ${strings.pricePerCopy}',
                              style: AppTypography.caption.copyWith(color: secondary),
                            ),
                          ],
                        ),
                      ),
                      AppMoney(
                        line.lineTotal,
                        style: AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              Container(height: 0.5, color: AppColors.separator.resolveFrom(context)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(strings.total, style: AppTypography.headline.copyWith(color: primary)),
                    ),
                    AppMoney(order.total, style: AppTypography.title3),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (order.notes case final notes? when notes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Header(strings.fieldNotes),
          SoftCard(
            child: Text(notes, style: AppTypography.body.copyWith(color: primary)),
          ),
        ],
        if (order.history.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _Header(strings.orderHistory),
          SoftCard(child: _Timeline(history: order.history)),
        ],
        if (order.status == OrderStatus.pending) ...[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: strings.actionCancelOrder,
            icon: AppIcons.close,
            variant: AppButtonVariant.destructive,
            expand: true,
            onPressed: submit.isBusy ? null : onCancel,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs, bottom: AppSpacing.xs),
    child: Text(
      text.toUpperCase(),
      style: AppTypography.footnote.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textSecondary.resolveFrom(context),
      ),
    ),
  );
}

/// The steps, newest first, each with who acted and the team's note.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.history});

  final List<OrderStatusChange> history;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final steps = history.reversed.toList();

    return Column(
      children: [
        for (final (index, step) in steps.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: orderStatusTone(step.status).resolve(context).foreground,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(child: Container(width: 2, color: AppColors.separator.resolveFrom(context))),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: index < steps.length - 1 ? AppSpacing.md : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderStatusText(strings, step.status),
                          style: AppTypography.subheadline.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary.resolveFrom(context),
                          ),
                        ),
                        Text(
                          [
                            AppDateFormat.dateTime(step.changedAt.toLocal(), locale),
                            step.changedByName ??
                                (step.actor == OrderActor.client ? strings.actorClient : strings.actorStaff),
                          ].join(' · '),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary.resolveFrom(context),
                          ),
                        ),
                        if (step.note case final note? when note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xxs),
                            child: Text(
                              note,
                              style: AppTypography.footnote.copyWith(
                                color: AppColors.textPrimary.resolveFrom(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
