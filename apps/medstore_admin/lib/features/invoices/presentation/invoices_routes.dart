import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import 'invoice_detail_page.dart';
import 'invoiced_products_page.dart';
import 'invoices_page.dart';
import 'new_invoice_cubit.dart';
import 'new_invoice_page.dart';

/// `/invoices`, `/invoices/new`, `/invoices/by-product` and `/invoices/:id`.
///
/// `/invoices/by-product?clientId=…&clientName=…` opens one teacher's unpaid invoices, all dates; without
/// a teacher it opens the current month.
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
      path: 'by-product',
      builder: (_, state) {
        final query = state.uri.queryParameters;
        final clientId = query['clientId'];
        final now = DateTime.now();
        final filter = clientId == null
            ? InvoicedProductsFilter(
                from: DateTime(now.year, now.month),
                to: DateTime(now.year, now.month, now.day),
              )
            : InvoicedProductsFilter(clientId: clientId, clientName: query['clientName'], onlyUnpaid: true);
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sl<SearchTeachers>()),
            RepositoryProvider.value(value: sl<ListInvoicedProducts>()),
          ],
          child: BlocProvider(
            create: (_) => LoadCubit<InvoicedProducts>(() => sl<ListInvoicedProducts>()(filter))..load(),
            child: InvoicedProductsPage(initialFilter: filter),
          ),
        );
      },
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
            RepositoryProvider.value(value: sl<CollectInvoicePayment>()),
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
