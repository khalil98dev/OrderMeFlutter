import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_teacher/features/notifications/domain/notification.dart';
import 'package:medstore_teacher/features/orders/domain/my_orders.dart';
import 'package:medstore_teacher/features/orders/presentation/order_detail_page.dart';
import 'package:medstore_teacher/features/orders/presentation/orders_page.dart';
import 'package:medstore_ui/medstore_ui.dart';

class _FakeNotifications extends Fake implements NotificationRepository {
  @override
  Stream<TeacherNotification> get arrivals => const Stream.empty();
}

class _FakeCancel extends Fake implements CancelMyOrder {}

class _FakeConfirm extends Fake implements ConfirmDelivery {}

/// Order n° 12: three copies of a 450 DA guide, just placed.
final _order = Order(
  id: 'o1',
  number: 12,
  clientId: 'c7',
  status: OrderStatus.pending,
  total: 1350,
  placedAt: DateTime(2026, 11, 7, 9),
  lines: const [
    OrderLine(
      id: 'l1',
      productId: 'p2',
      productName: 'Physique BAC',
      unitPrice: 450,
      quantity: 3,
      lineTotal: 1350,
    ),
  ],
  history: [
    OrderStatusChange(
      status: OrderStatus.pending,
      changedAt: DateTime(2026, 11, 7, 9),
      actor: OrderActor.client,
    ),
  ],
);

void main() {
  testWidgets('an order line shows its price per copy as text, never a function', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertino,
        locale: const Locale('fr'),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates,
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<NotificationRepository>.value(value: _FakeNotifications()),
            RepositoryProvider<CancelMyOrder>.value(value: _FakeCancel()),
            RepositoryProvider<ConfirmDelivery>.value(value: _FakeConfirm()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LoadCubit<Order>(() async => Result.ok(_order))..load()),
              BlocProvider(create: (_) => SubmitCubit<void>()),
              BlocProvider(
                create: (_) => MyOrdersCubit(
                  (_, _) async => const Result.ok(PagedList<OrderSummary>.empty()),
                  filter: const MyOrdersFilter(),
                ),
              ),
            ],
            child: const OrderDetailPage(orderId: 'o1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Physique BAC'), findsOneWidget);
    // MoneyFormat keeps the amount and its currency together with a non-breaking space.
    expect(find.text('450\u00a0DA / exemplaire'), findsOneWidget);
    expect(find.textContaining('Closure'), findsNothing);
  });
}
