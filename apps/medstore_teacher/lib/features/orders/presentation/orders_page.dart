import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/widgets/choice_chips.dart';
import '../../../app/widgets/soft_card.dart';
import '../../notifications/domain/notification.dart';
import '../domain/my_orders.dart';

typedef MyOrdersCubit = PagedListCubit<OrderSummary, MyOrdersFilter>;

/// The teacher's orders, newest first, filtered by status. A notification about an order (the team
/// moved it on) reloads the list, so the badge colors are always current.
///
/// Expects the app's [MyOrdersCubit] and [NotificationRepository] above it.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const _loadMoreDistance = 400.0;

  StreamSubscription<TeacherNotification>? _live;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MyOrdersCubit>();
    _live = context
        .read<NotificationRepository>()
        .arrivals
        .where((n) => n.link?.startsWith('orders/') ?? false)
        .listen((_) => cubit.load());
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<MyOrdersCubit>();
    final status = context.select<MyOrdersCubit, OrderStatus?>((cubit) => cubit.state.filter.status);

    return CupertinoPageScaffold(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.axis == Axis.vertical && scroll.metrics.extentAfter < _loadMoreDistance) {
            cubit.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(largeTitle: Text(strings.navOrders), border: null),
            CupertinoSliverRefreshControl(onRefresh: cubit.load),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: ChoiceChips<OrderStatus?>(
                  options: {
                    null: strings.filterAll,
                    for (final status in OrderStatus.values) status: orderStatusText(strings, status),
                  },
                  selected: status,
                  onChanged: (status) => cubit.setFilter(MyOrdersFilter(status: status)),
                ),
              ),
            ),
            const _OrdersSliver(),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _OrdersSliver extends StatelessWidget {
  const _OrdersSliver();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = context.watch<MyOrdersCubit>().state;

    if (state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoadView(
          isLoading: state.isLoading || state.page == 0,
          hasData: false,
          failure: state.failure,
          onRetry: context.read<MyOrdersCubit>().load,
          builder: (_) => const SizedBox.shrink(),
          empty: AppEmptyState(
            icon: AppIcons.cart,
            title: strings.noOrdersTitle,
            message: strings.noOrdersTeacherMessage,
            action: AppButton(label: strings.browseProducts, onPressed: () => context.go('/products')),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.separated(
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(padding: EdgeInsets.all(AppSpacing.md), child: CupertinoActivityIndicator());
          }
          final order = state.items[index];
          return OrderCard(order: order, onTap: () => context.go('/orders/${order.id}'));
        },
      ),
    );
  }
}

/// One order in the list: a status-colored icon, the number and date, copies, total and status.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final tone = orderStatusTone(order.status).resolve(context);

    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: tone.background, borderRadius: AppRadii.mdRadius),
            child: Icon(orderStatusIcon(order.status), color: tone.foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.orderNumber(order.number),
                  style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${AppDateFormat.dateTime(order.placedAt.toLocal(), locale)} · ${strings.copiesCount(order.totalQuantity)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppMoney(order.total, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.xxs),
              AppBadge(label: orderStatusText(strings, order.status), tone: orderStatusTone(order.status)),
            ],
          ),
        ],
      ),
    );
  }
}
