import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/debts.dart';
import 'client_debts_page.dart';
import 'debts_page.dart';

/// `/debts` (the overview) and `/debts/:clientId` (one teacher's items).
GoRoute debtsRoute() => GoRoute(
  path: '/debts',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<CreateDebt>()),
        RepositoryProvider.value(value: sl<SearchTeachers>()),
      ],
      child: BlocProvider(
        create: (_) => DebtOverviewCubit(
          (filter, page) => sl<ListDebtOverview>()(filter, page: page),
          filter: const DebtFilter(),
        )..load(),
        child: const DebtsPage(),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: ':clientId',
      builder: (_, state) {
        final clientId = state.pathParameters['clientId']!;
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sl<GetClientDebts>()),
            RepositoryProvider.value(value: sl<GetDebt>()),
            RepositoryProvider.value(value: sl<CreateDebt>()),
            RepositoryProvider.value(value: sl<SettleDebt>()),
            RepositoryProvider.value(value: sl<WriteOffDebt>()),
            RepositoryProvider.value(value: sl<SearchTeachers>()),
          ],
          child: BlocProvider(
            create: (_) =>
                LoadCubit<ClientDebts>(() => sl<GetClientDebts>()(ClientDebtsParams(clientId)))..load(),
            child: ClientDebtsPage(clientId: clientId),
          ),
        );
      },
    ),
  ],
);
