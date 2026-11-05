import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../domain/reports.dart';
import 'dashboard_page.dart';
import 'sales_page.dart';

/// `/dashboard`: the summary report.
GoRoute dashboardRoute() => GoRoute(
  path: '/dashboard',
  pageBuilder: (_, _) {
    final period = ReportPeriod.thisMonth(DateTime.now());
    return NoTransitionPage(
      child: RepositoryProvider.value(
        value: sl<GetSummaryReport>(),
        child: BlocProvider(
          create: (_) => LoadCubit<SummaryReport>(() => sl<GetSummaryReport>()(period))..load(),
          child: DashboardPage(initialPeriod: period),
        ),
      ),
    );
  },
);

/// `/reports`: the sales report.
GoRoute salesRoute() => GoRoute(
  path: '/reports',
  pageBuilder: (_, _) {
    final period = ReportPeriod.thisMonth(DateTime.now());
    return NoTransitionPage(
      child: RepositoryProvider.value(
        value: sl<GetSalesReport>(),
        child: BlocProvider(
          create: (_) =>
              LoadCubit<SalesReport>(() => sl<GetSalesReport>()(SalesParams(period, SalesGroupBy.product)))
                ..load(),
          child: SalesPage(initialPeriod: period),
        ),
      ),
    );
  },
);
