/// Shared code for the MedStore admin and teacher apps: core types, connectivity and shared features.
///
/// Apps import only this file. Anything under `src/` that is not exported here is private to the package.
library;

// Core
export 'src/core/bloc/app_bloc_observer.dart';
export 'src/core/cache/cache_store.dart';
export 'src/core/cache/hybrid_cache.dart';
export 'src/core/config/app_config.dart';
export 'src/core/error/failure.dart';
export 'src/core/json/json_map.dart';
export 'src/core/network/api_client.dart' show ApiClient, JsonDecoder;
export 'src/core/pagination/paged_list.dart';
export 'src/core/presentation/bytes_image_provider.dart';
export 'src/core/presentation/load_cubit.dart';
export 'src/core/presentation/paged_list_cubit.dart';
export 'src/core/presentation/stream_listenable.dart';
export 'src/core/presentation/submit_cubit.dart';
export 'src/core/realtime/realtime_client.dart' show RealtimeClient, RealtimeStatus;
export 'src/core/result/result.dart';
export 'src/core/usecase/use_case.dart';
// DI
export 'src/di/core_module.dart';
// Auth
export 'src/features/auth/domain/entities/session_user.dart';
export 'src/features/auth/domain/entities/user_role.dart';
export 'src/features/auth/domain/repositories/auth_repository.dart';
export 'src/features/auth/domain/usecases/change_password.dart';
export 'src/features/auth/domain/usecases/restore_session.dart';
export 'src/features/auth/domain/usecases/sign_in.dart';
export 'src/features/auth/domain/usecases/sign_out.dart';
export 'src/features/auth/presentation/auth_cubit.dart';
export 'src/features/auth/presentation/login_cubit.dart';
// Clients
export 'src/features/clients/domain/payment_terms.dart';
// Orders
export 'src/features/orders/data/order_model.dart';
export 'src/features/orders/data/order_repository_impl.dart' show OrderRepositoryImpl;
export 'src/features/orders/domain/entities/order.dart';
export 'src/features/orders/domain/repositories/order_repository.dart';
export 'src/features/orders/domain/usecases/get_order.dart';
// Products
export 'src/features/products/data/product_model.dart';
export 'src/features/products/data/product_repository_impl.dart' show ProductRepositoryImpl;
export 'src/features/products/domain/entities/product.dart';
export 'src/features/products/domain/entities/product_query.dart';
export 'src/features/products/domain/repositories/product_repository.dart';
export 'src/features/products/domain/usecases/product_usecases.dart';
export 'src/features/products/presentation/product_detail_cubit.dart';
export 'src/features/products/presentation/product_images.dart';
export 'src/features/products/presentation/products_cubit.dart';
// Settings
export 'src/features/settings/presentation/locale_cubit.dart';
