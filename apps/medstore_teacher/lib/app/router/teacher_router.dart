import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../features/auth/login_page.dart';
import '../../features/products/product_detail_page.dart';
import '../../features/products/products_page.dart';
import '../../features/profile/profile_page.dart';
import '../di/injection.dart';
import '../shell/coming_soon_page.dart';
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
  TeacherTab(
    path: '/products',
    icon: CupertinoIcons.book,
    activeIcon: CupertinoIcons.book_fill,
    label: _products,
  ),
  TeacherTab(
    path: '/orders',
    icon: CupertinoIcons.cart,
    activeIcon: CupertinoIcons.cart_fill,
    label: _orders,
  ),
  TeacherTab(
    path: '/notifications',
    icon: CupertinoIcons.bell,
    activeIcon: CupertinoIcons.bell_fill,
    label: _notifications,
  ),
  TeacherTab(
    path: '/profile',
    icon: CupertinoIcons.person_crop_circle,
    activeIcon: CupertinoIcons.person_crop_circle_fill,
    label: _profile,
  ),
];

String _products(AppStrings s) => s.navProducts;
String _orders(AppStrings s) => s.navOrders;
String _notifications(AppStrings s) => s.navNotifications;
String _profile(AppStrings s) => s.navProfile;

/// Routes and the auth guard: unknown → splash, signed out → login, signed in → the tabs.
class TeacherRouter {
  TeacherRouter(AuthCubit auth) : _refresh = StreamListenable(auth.stream) {
    config = GoRouter(
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
        // One navigator per tab, kept alive: each tab keeps its scroll position and its pushed pages.
        // Same order as [teacherTabs].
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => TeacherShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [_productsRoute()]),
            StatefulShellBranch(routes: [_comingSoonRoute(teacherTabs[1])]),
            StatefulShellBranch(routes: [_comingSoonRoute(teacherTabs[2])]),
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

  /// `/products` (the list) and `/products/:id` (one book).
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

  static GoRoute _comingSoonRoute(TeacherTab tab) => GoRoute(
    path: tab.path,
    pageBuilder: (_, _) => NoTransitionPage(child: ComingSoonPage(tab: tab)),
  );

  final StreamListenable _refresh;
  late final GoRouter config;

  void dispose() {
    config.dispose();
    _refresh.dispose();
  }
}
