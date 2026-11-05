import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../features/auth/login_page.dart';
import '../../features/debts/presentation/debts_routes.dart';
import '../../features/invoices/presentation/invoices_routes.dart';
import '../../features/orders/presentation/orders_routes.dart';
import '../../features/products/products_routes.dart';
import '../../features/reports/presentation/reports_routes.dart';
import '../../features/schools/presentation/schools_routes.dart';
import '../../features/security/presentation/security_routes.dart';
import '../../features/settings/settings_routes.dart';
import '../../features/teachers/presentation/teachers_routes.dart';
import '../../features/wallets/presentation/wallets_routes.dart';
import '../shell/admin_shell.dart';
import '../shell/coming_soon_page.dart';
import '../shell/splash_page.dart';
import 'admin_destinations.dart';

abstract final class AdminRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/dashboard';
}

/// Routes and the auth guard. The guard re-runs on every [AuthCubit] state:
/// unknown → splash, signed out → login, signed in → the app.
class AdminRouter {
  AdminRouter(AuthCubit auth) : _refresh = StreamListenable(auth.stream) {
    config = GoRouter(
      initialLocation: AdminRoutes.home,
      refreshListenable: _refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        return switch (auth.state) {
          AuthUnknown() => location == AdminRoutes.splash ? null : AdminRoutes.splash,
          Unauthenticated() => location == AdminRoutes.login ? null : AdminRoutes.login,
          Authenticated() =>
            location == AdminRoutes.login || location == AdminRoutes.splash ? AdminRoutes.home : null,
        };
      },
      routes: [
        GoRoute(
          path: AdminRoutes.splash,
          pageBuilder: (_, _) => const NoTransitionPage(child: SplashPage()),
        ),
        GoRoute(
          path: AdminRoutes.login,
          pageBuilder: (_, _) => const NoTransitionPage(child: LoginPage()),
        ),
        // Each sidebar entry is a branch with its own navigator, kept alive (IndexedStack): switching back
        // shows the page as it was left, without reloading.
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AdminShell(shell: shell),
          branches: [
            for (final destination in adminDestinations)
              StatefulShellBranch(routes: [_routeFor(destination)]),
          ],
        ),
      ],
    );
  }

  /// Every built section gets its own routes; notifications show "coming soon" until they are built.
  static GoRoute _routeFor(AdminDestination destination) => switch (destination.path) {
    '/orders' => ordersRoute(),
    '/products' => productsRoute(),
    '/teachers' => teachersRoute(),
    '/schools' => schoolsRoute(),
    '/wallet' => walletsRoute(),
    '/invoices' => invoicesRoute(),
    '/debts' => debtsRoute(),
    '/dashboard' => dashboardRoute(),
    '/reports' => salesRoute(),
    '/security' => securityRoute(),
    '/settings' => settingsRoute(),
    _ => GoRoute(
      path: destination.path,
      pageBuilder: (_, _) => NoTransitionPage(child: ComingSoonPage(destination: destination)),
    ),
  };

  final StreamListenable _refresh;
  late final GoRouter config;

  void dispose() {
    config.dispose();
    _refresh.dispose();
  }
}
