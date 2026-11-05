import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../app/di/injection.dart';
import 'domain/billing_settings.dart';
import 'settings_page.dart';

/// `/settings`.
GoRoute settingsRoute() => GoRoute(
  path: '/settings',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<SaveBillingSettings>()),
        RepositoryProvider.value(value: sl<ChangePassword>()),
      ],
      child: BlocProvider(
        create: (_) => LoadCubit<BillingSettings>(() => sl<GetBillingSettings>()(const NoParams()))..load(),
        child: const SettingsPage(),
      ),
    ),
  ),
);
