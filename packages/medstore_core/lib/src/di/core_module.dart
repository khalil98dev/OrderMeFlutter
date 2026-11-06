import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import '../core/cache/hive_cache_store.dart';
import '../core/cache/hybrid_cache.dart';
import '../core/cache/memory_cache_store.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/token_refresher.dart';
import '../core/network/token_store.dart';
import '../core/realtime/realtime_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/entities/user_role.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/change_password.dart';
import '../features/auth/domain/usecases/restore_session.dart';
import '../features/auth/domain/usecases/sign_in.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/auth/presentation/login_cubit.dart';
import '../features/orders/data/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/domain/usecases/get_order.dart';
import '../features/products/data/product_repository_impl.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/domain/usecases/product_usecases.dart';
import '../features/products/presentation/product_images.dart';
import '../features/products/presentation/products_cubit.dart';
import '../features/settings/data/settings_store.dart';
import '../features/settings/presentation/locale_cubit.dart';

/// Registers everything both apps share: config, network, cache, realtime and auth.
///
/// Each app calls this first from its own `configureDependencies`, with the role it accepts, then
/// registers its own features. Everything is lazy: nothing is built until first used.
///
/// [productListPath] is where product lists come from: the teacher's own (`/api/products`) or, for the
/// admin app, every teacher's (`/api/admin/products`).
Future<void> registerCoreModule(
  GetIt sl, {
  required UserRole appRole,
  AppConfig? config,
  String productListPath = ProductRepositoryImpl.defaultListPath,
}) async {
  final cacheDir = await getApplicationSupportDirectory();
  Hive.init('${cacheDir.path}/cache');

  final appConfig = config ?? AppConfig.fromEnvironment();
  trustDevCertificate(appConfig);

  sl
    // Core
    ..registerSingleton<AppConfig>(appConfig)
    ..registerLazySingleton(
      // Ad-hoc signed macOS builds have no keychain access group, so use the login keychain there.
      () => const FlutterSecureStorage(mOptions: MacOsOptions(usesDataProtectionKeychain: false)),
    )
    ..registerLazySingleton(() => TokenStore(sl()))
    ..registerLazySingleton(() => TokenRefresher(dio: Dio(baseOptions(sl())), store: sl()))
    ..registerLazySingleton(() => createApiDio(config: sl(), store: sl(), refresher: sl()))
    ..registerLazySingleton(() => ApiClient(sl()))
    ..registerLazySingleton(() => HybridCache(memory: MemoryCacheStore(), disk: HiveCacheStore()))
    ..registerLazySingleton(() => RealtimeClient(config: sl(), tokens: sl(), refresher: sl()))
    // Auth
    ..registerLazySingleton(() => AuthRemoteDataSource(sl()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), tokens: sl(), refresher: sl(), cache: sl(), realtime: sl()),
    )
    ..registerLazySingleton(() => SignIn(sl(), allowedRole: appRole))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => RestoreSession(sl(), allowedRole: appRole))
    ..registerLazySingleton(() => AuthCubit(restoreSession: sl(), signOut: sl(), repository: sl()))
    ..registerFactory(() => LoginCubit(sl()))
    ..registerLazySingleton(() => ChangePassword(sl()))
    // Settings
    ..registerLazySingleton(SettingsStore.new)
    ..registerLazySingleton(() => LocaleCubit(sl()))
    // Products (reading; the admin app registers the writing side)
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(api: sl(), cache: sl(), listPath: productListPath),
    )
    ..registerLazySingleton(() => WatchProducts(sl()))
    ..registerLazySingleton(() => GetProduct(sl()))
    ..registerLazySingleton(() => ProductImages(sl()))
    ..registerFactory(() => ProductsCubit(sl()))
    // Orders (reading one; each app lists and changes them through its own endpoints)
    ..registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetOrder(sl()));
}
