import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../domain/security.dart';
import 'role_matrix_cubit.dart';
import 'role_matrix_page.dart';
import 'security_page.dart';

/// `/security` (roles, users, resources) and `/security/roles/:name` (a role's permission grid).
GoRoute securityRoute() => GoRoute(
  path: '/security',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<CreateRole>()),
        RepositoryProvider.value(value: sl<CreateUser>()),
        RepositoryProvider.value(value: sl<SetUserRoles>()),
        RepositoryProvider.value(value: sl<DeactivateUser>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoadCubit<List<Role>>(() => sl<ListRoles>()(const NoParams()))..load()),
          BlocProvider(
            create: (_) => LoadCubit<List<AdminUser>>(() => sl<ListUsers>()(const NoParams()))..load(),
          ),
          BlocProvider(
            create: (_) =>
                LoadCubit<List<SecuredResource>>(() => sl<ListSecuredResources>()(const NoParams()))..load(),
          ),
        ],
        child: const SecurityPage(),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: 'roles/:name',
      builder: (_, state) => BlocProvider(
        create: (_) => RoleMatrixCubit(
          getMatrix: sl(),
          saveMatrix: sl(),
          role: Uri.decodeComponent(state.pathParameters['name']!),
        )..load(),
        child: const RoleMatrixPage(),
      ),
    ),
  ],
);
