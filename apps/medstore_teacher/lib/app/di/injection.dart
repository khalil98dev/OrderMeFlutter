import 'package:get_it/get_it.dart';
import 'package:medstore_core/medstore_core.dart';

/// The teacher app's service locator. Only `main`, the app root, routes and tests read from it; widgets
/// below get their Cubits through `BlocProvider`.
final GetIt sl = GetIt.instance;

/// The role this app accepts at sign-in. A team account is refused with [WrongAppFailure].
const UserRole appRole = UserRole.client;

/// Registers everything the app needs, once, before `runApp`.
///
/// Rules: data sources, repositories and use cases are lazy singletons; screen Cubits are factories
/// (a fresh one per screen, closed by its `BlocProvider`); app-wide Cubits (auth, locale) are singletons.
Future<void> configureDependencies() async {
  await registerCoreModule(sl, appRole: appRole);
  // Teacher features (my products, my orders, notifications) register here.
}
