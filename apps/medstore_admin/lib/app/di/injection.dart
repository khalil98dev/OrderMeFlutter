import 'package:get_it/get_it.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../features/debts/data/debt_repository_impl.dart';
import '../../features/debts/domain/debts.dart';
import '../../features/invoices/data/invoice_repository_impl.dart';
import '../../features/invoices/domain/invoice_repository.dart';
import '../../features/notifications/data/notification_repository_impl.dart';
import '../../features/notifications/domain/notification.dart';
import '../../features/notifications/presentation/unread_cubit.dart';
import '../../features/orders/data/admin_order_repository_impl.dart';
import '../../features/orders/domain/admin_orders.dart';
import '../../features/products/data/admin_product_repository_impl.dart';
import '../../features/products/domain/admin_product_repository.dart';
import '../../features/products/domain/admin_product_usecases.dart';
import '../../features/reports/data/report_repository_impl.dart';
import '../../features/reports/domain/reports.dart';
import '../../features/schools/data/school_repository_impl.dart';
import '../../features/schools/domain/school_repository.dart';
import '../../features/security/data/security_repository_impl.dart';
import '../../features/security/domain/security.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/billing_settings.dart';
import '../../features/teachers/data/teacher_directory_impl.dart';
import '../../features/teachers/data/teacher_repository_impl.dart';
import '../../features/teachers/domain/teacher_directory.dart';
import '../../features/teachers/domain/teacher_repository.dart';
import '../../features/wallets/data/wallet_repository_impl.dart';
import '../../features/wallets/domain/wallet_repository.dart';

/// The admin app's service locator. Only `main`, the app root, routes and tests read from it; widgets
/// below get their Cubits through `BlocProvider`.
final GetIt sl = GetIt.instance;

/// The role this app accepts at sign-in. A teacher account is refused with [WrongAppFailure].
const UserRole appRole = UserRole.admin;

/// Registers everything the app needs, once, before `runApp`.
///
/// Rules: repositories and use cases are lazy singletons; screen Cubits are built by the routes (a
/// fresh one per screen, closed by its `BlocProvider`); app-wide Cubits (auth, locale) are singletons.
Future<void> configureDependencies() async {
  // The team lists every teacher's products, filtered by teacher.
  await registerCoreModule(sl, appRole: appRole, productListPath: '/api/admin/products');

  sl
    // Products (writing; reading comes from the core module)
    ..registerLazySingleton<AdminProductRepository>(
      () => AdminProductRepositoryImpl(api: sl(), cache: sl(), images: sl()),
    )
    ..registerLazySingleton(() => CreateProduct(sl()))
    ..registerLazySingleton(() => UpdateProduct(sl()))
    ..registerLazySingleton(() => ChangeProductCover(sl()))
    ..registerLazySingleton(() => DeleteProduct(sl()))
    // Teachers
    ..registerLazySingleton<TeacherDirectory>(() => TeacherDirectoryImpl(sl()))
    ..registerLazySingleton(() => SearchTeachers(sl()))
    ..registerLazySingleton<TeacherRepository>(() => TeacherRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListTeachers(sl()))
    ..registerLazySingleton(() => GetTeacher(sl()))
    ..registerLazySingleton(() => SaveTeacher(sl()))
    ..registerLazySingleton(() => DeactivateTeacher(sl()))
    ..registerLazySingleton(() => GetStatement(sl()))
    ..registerLazySingleton(() => DownloadStatementPdf(sl()))
    // Schools
    ..registerLazySingleton<SchoolRepository>(() => SchoolRepositoryImpl(api: sl(), cache: sl()))
    ..registerLazySingleton(() => ListSchools(sl()))
    ..registerLazySingleton(() => SaveSchool(sl()))
    // Orders
    ..registerLazySingleton<AdminOrderRepository>(() => AdminOrderRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListOrders(sl()))
    ..registerLazySingleton(() => PlaceOrder(sl()))
    ..registerLazySingleton(() => ReviseOrder(sl()))
    ..registerLazySingleton(() => ChangeOrderStatus(sl()))
    // Wallets
    ..registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListWallets(sl()))
    ..registerLazySingleton(() => GetWallet(sl()))
    ..registerLazySingleton(() => ListTransactions(sl()))
    ..registerLazySingleton(() => RecordDeposit(sl()))
    ..registerLazySingleton(() => RecordWithdrawal(sl()))
    ..registerLazySingleton(() => SettleWallet(sl()))
    ..registerLazySingleton(() => VoidTransaction(sl()))
    ..registerLazySingleton(() => DownloadReceipt(sl()))
    // Invoices
    ..registerLazySingleton<InvoiceRepository>(() => InvoiceRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListInvoices(sl()))
    ..registerLazySingleton(() => GetInvoice(sl()))
    ..registerLazySingleton(() => ListUninvoiced(sl()))
    ..registerLazySingleton(() => IssueInvoice(sl()))
    ..registerLazySingleton(() => VoidInvoice(sl()))
    ..registerLazySingleton(() => SettleInvoice(sl()))
    ..registerLazySingleton(() => DownloadInvoicePdf(sl()))
    // Debts
    ..registerLazySingleton<DebtRepository>(() => DebtRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListDebtOverview(sl()))
    ..registerLazySingleton(() => GetClientDebts(sl()))
    ..registerLazySingleton(() => GetDebt(sl()))
    ..registerLazySingleton(() => CreateDebt(sl()))
    ..registerLazySingleton(() => SettleDebt(sl()))
    ..registerLazySingleton(() => WriteOffDebt(sl()))
    // Notifications
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(api: sl(), realtime: sl()),
    )
    ..registerLazySingleton(() => ListNotifications(sl()))
    ..registerLazySingleton(() => MarkNotificationRead(sl()))
    ..registerLazySingleton(() => MarkAllNotificationsRead(sl()))
    // The sidebar's unread badge: one for the app, started at sign-in.
    ..registerLazySingleton(() => UnreadCubit(sl()))
    // Reports
    ..registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetSummaryReport(sl()))
    ..registerLazySingleton(() => GetSalesReport(sl()))
    // Settings
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetBillingSettings(sl()))
    ..registerLazySingleton(() => SaveBillingSettings(sl()))
    // Security
    ..registerLazySingleton<SecurityRepository>(() => SecurityRepositoryImpl(sl()))
    ..registerLazySingleton(() => ListSecuredResources(sl()))
    ..registerLazySingleton(() => ListRoles(sl()))
    ..registerLazySingleton(() => CreateRole(sl()))
    ..registerLazySingleton(() => GetRoleMatrix(sl()))
    ..registerLazySingleton(() => SaveRoleMatrix(sl()))
    ..registerLazySingleton(() => ListUsers(sl()))
    ..registerLazySingleton(() => CreateUser(sl()))
    ..registerLazySingleton(() => SetUserRoles(sl()))
    ..registerLazySingleton(() => DeactivateUser(sl()));
}
