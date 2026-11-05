import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import 'invoice_detail_page.dart';
import 'invoices_page.dart';
import 'new_invoice_cubit.dart';
import 'new_invoice_page.dart';

/// `/invoices`, `/invoices/new` and `/invoices/:id`.
GoRoute invoicesRoute() => GoRoute(
  path: '/invoices',
  pageBuilder: (_, _) => NoTransitionPage(
    child: RepositoryProvider.value(
      value: sl<SearchTeachers>(),
      child: BlocProvider(
        create: (_) => InvoicesCubit(
          (filter, page) => sl<ListInvoices>()(filter, page: page),
          filter: const InvoiceFilter(),
        )..load(),
        child: const InvoicesPage(),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: 'new',
      builder: (_, _) => RepositoryProvider.value(
        value: sl<SearchTeachers>(),
        child: BlocProvider(
          create: (_) => NewInvoiceCubit(listUninvoiced: sl(), issueInvoice: sl()),
          child: const NewInvoicePage(),
        ),
      ),
    ),
    GoRoute(
      path: ':id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sl<VoidInvoice>()),
            RepositoryProvider.value(value: sl<SettleInvoice>()),
            RepositoryProvider.value(value: sl<DownloadInvoicePdf>()),
          ],
          child: BlocProvider(
            create: (_) => LoadCubit<Invoice>(() => sl<GetInvoice>()(id))..load(),
            child: const InvoiceDetailPage(),
          ),
        );
      },
    ),
  ],
);
