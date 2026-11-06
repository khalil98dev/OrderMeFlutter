import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../features/auth/login_page.dart';
import '../../features/cart/cart_bar.dart';
import '../../features/cart/cart_page.dart';
import '../../features/notifications/domain/notification.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/orders/domain/my_orders.dart';
import '../../features/orders/presentation/order_detail_page.dart';
import '../../features/orders/presentation/orders_page.dart';
import '../../features/products/product_detail_page.dart';
import '../../features/products/products_page.dart';
import '../../features/profile/profile_page.dart';
import '../di/injection.dart';
import '../shell/splash_page.dart';
import '../shell/teacher_shell.dart';

abstract final class TeacherRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/products';
}

/// One tab and its route. The order here is the tab bar's order and the shell's branch index.
class TeacherTab {
  const TeacherTab({required this.path, required this.icon, required this.activeIcon, required this.label});

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String Function(AppStrings strings) label;
}

const teacherTabs = <TeacherTab>[
  TeacherTab(path: '/products', icon: AppIcons.products, activeIcon: AppIcons.products, label: _products),
  TeacherTab(path: '/orders', icon: AppIcons.orders, activeIcon: AppIcons.orders, label: _orders),
  TeacherTab(
    path: '/notifications',
    icon: AppIcons.notifications,
    activeIcon: AppIcons.notifications,
    label: _notifications,
  ),
  TeacherTab(path: '/profile', icon: AppIcons.profile, activeIcon: AppIcons.profile, label: _profile),
];

String _products(AppStrings s) => s.navProducts;
String _orders(AppStrings s) => s.navOrders;
String _notifications(AppStrings s) => s.navNotifications;
String _profile(AppStrings s) => s.navProfile;

/// Routes and the auth guard: unknown → splash, signed out → login, signed in → the tabs.
class TeacherRouter {
  TeacherRouter(AuthCubit auth) : _refresh = StreamListenable(auth.stream) {
    config = GoRouter(
      navigatorKey: _rootKey,
      initialLocation: TeacherRoutes.home,
      refreshListenable: _refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        return switch (auth.state) {
          AuthUnknown() => location == TeacherRoutes.splash ? null : TeacherRoutes.splash,
          Unauthenticated() => location == TeacherRoutes.login ? null : TeacherRoutes.login,
          Authenticated() =>
            location == TeacherRoutes.login || location == TeacherRoutes.splash ? TeacherRoutes.home : null,
        };
      },
      routes: [
        GoRoute(
          path: TeacherRoutes.splash,
          pageBuilder: (_, _) => const NoTransitionPage(child: SplashPage()),
        ),
        GoRoute(
          path: TeacherRoutes.login,
          pageBuilder: (_, _) => const NoTransitionPage(child: LoginPage()),
        ),
        // Over the tabs, as a sheet that slides up.
        GoRoute(
          path: CartBar.route,
          parentNavigatorKey: _rootKey,
          pageBuilder: (_, state) => CupertinoPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: MultiRepositoryProvider(
              providers: [RepositoryProvider.value(value: sl<PlaceOrder>())],
              child: BlocProvider(create: (_) => SubmitCubit<Order>(), child: const CartPage()),
            ),
          ),
        ),
        // One navigator per tab, kept alive: each tab keeps its scroll position and its pushed pages.
        // Same order as [teacherTabs].
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => TeacherShell(shell: shell, location: state.uri.path),
          branches: [
            StatefulShellBranch(routes: [_productsRoute()]),
            StatefulShellBranch(routes: [_ordersRoute()]),
            StatefulShellBranch(routes: [_notificationsRoute()]),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (_, _) => const NoTransitionPage(child: ProfilePage()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static final _rootKey = GlobalKey<NavigatorState>();

  /// `/products` (the grid) and `/products/:id` (one book).
  static GoRoute _productsRoute() => GoRoute(
    path: '/products',
    pageBuilder: (_, _) => NoTransitionPage(
      child: BlocProvider(create: (_) => sl<ProductsCubit>()..load(), child: const ProductsPage()),
    ),
    routes: [
      GoRoute(
        path: ':id',
        builder: (_, state) => BlocProvider(
          create: (_) => ProductDetailCubit(
            sl(),
            productId: state.pathParameters['id']!,
            initial: state.extra as Product?, // the list hands over the product it already has
          )..load(),
          child: const ProductDetailPage(),
        ),
      ),
    ],
  );

  /// `/orders` (the app's list) and `/orders/:id` (one order, its tracker and actions).
  static GoRoute _ordersRoute() => GoRoute(
    path: '/orders',
    pageBuilder: (_, _) => const NoTransitionPage(child: OrdersPage()),
    routes: [
      GoRoute(
        path: ':id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(value: sl<CancelMyOrder>()),
              RepositoryProvider.value(value: sl<ConfirmDelivery>()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => LoadCubit<Order>(() => sl<GetOrder>()(id))..load()),
                BlocProvider(create: (_) => SubmitCubit<void>()),
              ],
              child: OrderDetailPage(orderId: id),
            ),
          );
        },
      ),
    ],
  );

  static GoRoute _notificationsRoute() => GoRoute(
    path: '/notifications',
    pageBuilder: (_, _) => NoTransitionPage(
      child: BlocProvider(
        create: (_) => NotificationsCubit(
          (filter, page) => sl<NotificationRepository>().list(filter, page: page),
          filter: const NotificationFilter(),
        )..load(),
        child: const NotificationsPage(),
      ),
    ),
  );

  final StreamListenable _refresh;
  late final GoRouter config;

  void dispose() {
    config.dispose();
    _refresh.dispose();
  }
}
