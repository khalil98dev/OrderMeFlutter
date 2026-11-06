import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/di/injection.dart';
import '../../../app/shell/admin_page.dart';
import '../../notifications/presentation/reload_on_notification.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/admin_orders.dart';
import 'order_detail_page.dart';
import 'order_editor_cubit.dart';
import 'order_editor_page.dart';
import 'orders_page.dart';

/// `/orders`, `/orders/new`, `/orders/:id` and `/orders/:id/edit`.
GoRoute ordersRoute() => GoRoute(
  path: '/orders',
  pageBuilder: (_, _) => NoTransitionPage(
    child: RepositoryProvider.value(
      value: sl<SearchTeachers>(),
      child: BlocProvider(
        create: (_) =>
            OrdersCubit((filter, page) => sl<ListOrders>()(filter, page: page), filter: const OrderFilter())
              ..load(),
        // A new order or a status change pushed live shows up without a manual refresh.
        child: ReloadOnNotification(
          when: (notification) => notification.orderId != null,
          onArrival: (context) => unawaited(context.read<OrdersCubit>().load()),
          child: const OrdersPage(),
        ),
      ),
    ),
  ),
  routes: [
    GoRoute(path: 'new', builder: (_, _) => _editor(null)),
    GoRoute(
      path: ':id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return RepositoryProvider.value(
          value: sl<ChangeOrderStatus>(),
          child: BlocProvider(
            create: (_) => LoadCubit<Order>(() => sl<GetOrder>()(id))..load(),
            // Its status changed elsewhere (the teacher cancelled it, a colleague moved it on).
            child: ReloadOnNotification(
              when: (notification) => notification.orderId == id,
              onArrival: (context) => unawaited(context.read<LoadCubit<Order>>().load()),
              child: const OrderDetailPage(),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (_, state) => switch (state.extra) {
            final Order order => _editor(order),
            // Opened without the order in hand: load it first.
            _ => _LoadThenEdit(orderId: state.pathParameters['id']!),
          },
        ),
      ],
    ),
  ],
);

Widget _editor(Order? order) => RepositoryProvider.value(
  value: sl<SearchTeachers>(),
  child: BlocProvider(
    create: (_) =>
        OrderEditorCubit(placeOrder: sl(), reviseOrder: sl(), watchProducts: sl(), existing: order)..start(),
    child: OrderEditorPage(orderNumber: order?.number),
  ),
);

class _LoadThenEdit extends StatelessWidget {
  const _LoadThenEdit({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoadCubit<Order>(() => sl<GetOrder>()(orderId))..load(),
      child: BlocBuilder<LoadCubit<Order>, LoadState<Order>>(
        builder: (context, state) => switch (state.data) {
          final order? => _editor(order),
          null => AdminPage(
            title: AppStrings.of(context).reviseOrder,
            child: AppLoadView(
              isLoading: state.failure == null,
              hasData: false,
              failure: state.failure,
              onRetry: context.read<LoadCubit<Order>>().load,
              empty: const SizedBox.shrink(),
              builder: (_) => const SizedBox.shrink(),
            ),
          ),
        },
      ),
    );
  }
}
