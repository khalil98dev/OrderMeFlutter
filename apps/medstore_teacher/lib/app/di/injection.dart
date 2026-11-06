import 'package:get_it/get_it.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../features/cart/cart_cubit.dart';
import '../../features/notifications/data/notification_repository_impl.dart';
import '../../features/notifications/domain/notification.dart';
import '../../features/notifications/presentation/unread_cubit.dart';
import '../../features/orders/data/my_order_repository_impl.dart';
import '../../features/orders/domain/my_orders.dart';
import '../../features/orders/presentation/orders_page.dart';

/// The teacher app's service locator. Only `main`, the app root, routes and tests read from it; widgets
/// below get their Cubits through `BlocProvider`.
final GetIt sl = GetIt.instance;

/// The role this app accepts at sign-in. A team account is refused with [WrongAppFailure].
const UserRole appRole = UserRole.client;

/// Registers everything the app needs, once, before `runApp`.
///
/// Rules: data sources, repositories and use cases are lazy singletons; screen Cubits are factories
/// (a fresh one per screen, closed by its `BlocProvider`); app-wide Cubits (auth, locale, cart, unread
/// count, the orders list) are singletons.
Future<void> configureDependencies() async {
  await registerCoreModule(sl, appRole: appRole);
  registerTeacherFeatures(sl);
}

/// The teacher's own features. Separate so tests can register them over fakes.
void registerTeacherFeatures(GetIt sl) {
  sl
    // Cart
    ..registerLazySingleton(CartCubit.new)
    // My orders
    ..registerLazySingleton<MyOrderRepository>(() => MyOrderRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListMyOrders(sl()))
    ..registerLazySingleton(() => PlaceOrder(sl()))
    ..registerLazySingleton(() => CancelMyOrder(sl()))
    ..registerLazySingleton(() => ConfirmDelivery(sl()))
    ..registerLazySingleton(
      () => MyOrdersCubit(
        (filter, page) => sl<ListMyOrders>()(filter, page: page),
        filter: const MyOrdersFilter(),
      ),
    )
    // Notifications
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(api: sl(), realtime: sl()),
    )
    ..registerLazySingleton(() => UnreadCubit(sl()));
}
