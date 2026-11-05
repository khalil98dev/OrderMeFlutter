// Every admin feature against the running API (Development), through the app's own repositories.
//
// Skipped unless MEDSTORE_ADMIN_PASSWORD is set. Run with the API started:
//   MEDSTORE_ADMIN_PASSWORD=... flutter test test/live/live_api_test.dart
// Optional: MEDSTORE_API_URL (default http://localhost:60613), MEDSTORE_ADMIN_USER (default admin).
//
// It creates its own data (a school, a teacher, products, an order, money movements, an invoice, a debt,
// a role and a staff user), all named "Live <run>", and deactivates the teacher and the user at the end.
// The billing settings are put back as they were.
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/debts/data/debt_repository_impl.dart';
import 'package:medstore_admin/features/debts/domain/debts.dart';
import 'package:medstore_admin/features/invoices/data/invoice_repository_impl.dart';
import 'package:medstore_admin/features/invoices/domain/invoice.dart';
import 'package:medstore_admin/features/orders/data/admin_order_repository_impl.dart';
import 'package:medstore_admin/features/orders/domain/admin_orders.dart';
import 'package:medstore_admin/features/products/data/admin_product_repository_impl.dart';
import 'package:medstore_admin/features/products/domain/product_draft.dart';
import 'package:medstore_admin/features/reports/data/report_repository_impl.dart';
import 'package:medstore_admin/features/reports/domain/reports.dart';
import 'package:medstore_admin/features/schools/data/school_repository_impl.dart';
import 'package:medstore_admin/features/schools/domain/school.dart';
import 'package:medstore_admin/features/security/data/security_repository_impl.dart';
import 'package:medstore_admin/features/security/domain/security.dart';
import 'package:medstore_admin/features/settings/data/settings_repository_impl.dart';
import 'package:medstore_admin/features/teachers/data/teacher_repository_impl.dart';
import 'package:medstore_admin/features/teachers/domain/teacher.dart';
import 'package:medstore_admin/features/wallets/data/wallet_repository_impl.dart';
import 'package:medstore_admin/features/wallets/domain/wallet.dart';
import 'package:medstore_core/medstore_core.dart';

import '../helpers/fake_api.dart' show MemoryStore, okValue;

final _env = Platform.environment;
final _password = _env['MEDSTORE_ADMIN_PASSWORD'];
final _baseUrl = _env['MEDSTORE_API_URL'] ?? 'http://localhost:60613';
final _run = DateTime.now().millisecondsSinceEpoch.toString().substring(5);

/// A 1×1 PNG.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Signs in like the app does, then sends the access token with every call (a bare client: no refresh
/// is needed in a run that lasts seconds).
Future<ApiClient> _signedIn(String userName, String password) async {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl, headers: const {'X-Api-Version': '1'}));
  final login = await ApiClient(dio).post(
    '/api/auth/login',
    data: {'userName': userName, 'password': password},
    decode: (json) => (json! as Map<String, Object?>)['accessToken']! as String,
  );
  final token = okValue(login);
  dio.options.headers['Authorization'] = 'Bearer $token';
  return ApiClient(dio);
}

void _ok<T>(String step, Result<T> result) {
  if (result case Err(:final failure)) fail('$step failed: $failure ${failure.detail}');
}

void main() {
  final skip = _password == null ? 'Set MEDSTORE_ADMIN_PASSWORD (and start the API) to run' : null;

  test(
    'every admin feature works against the running API',
    () async {
      final api = await _signedIn(_env['MEDSTORE_ADMIN_USER'] ?? 'admin', _password!);
      final cache = HybridCache(memory: MemoryStore(), disk: MemoryStore());
      final log = <String>[];
      void step(String name) => log.add(name);

      // ---------------------------------------------------------------- 1. Auth: me (login done above)
      final me = okValue(await api.get('/api/auth/me', decode: (json) => json! as Map<String, Object?>));
      expect((me['roles']! as List).contains('Client'), isFalse);
      step('auth: login, me');

      // ---------------------------------------------------------------- Settings first: AutoSettle off
      final settingsRepo = SettingsRepositoryImpl(api);
      final originalSettings = okValue(await settingsRepo.billing());
      _ok(
        'settings put',
        await settingsRepo.saveBilling(autoSettle: false, defaultPaymentTerms: PaymentTerms.endOfMonth),
      );
      step('settings: get, put');

      try {
        // -------------------------------------------------------------- 2. Schools
        final schools = SchoolRepositoryImpl(api: api, cache: cache);
        final school = okValue(
          await schools.create(SchoolDraft(name: 'Live $_run Lycée', wilayaText: '16', city: 'Alger')),
        );
        _ok(
          'school update',
          await schools.update(school.id, SchoolDraft(name: 'Live $_run Lycée', wilayaText: '31')),
        );
        final schoolList = okValue(await schools.list(SchoolFilter(search: 'Live $_run')));
        expect(schoolList.single.wilayaCode, 31);
        step('schools: create, update, list');

        // -------------------------------------------------------------- 3. Teachers
        final teachers = TeacherRepositoryImpl(api);
        final teacher = okValue(
          await teachers.create(
            TeacherDraft(
              fullName: 'Live $_run Amina',
              userName: 'live$_run',
              password: 'Live-$_run-pass',
              phone: '0550123456',
              schoolId: school.id,
            ),
          ),
        );
        _ok(
          'teacher update',
          await teachers.update(
            teacher.id,
            TeacherDraft(
              fullName: 'Live $_run Amina B.',
              schoolId: school.id,
              paymentTerms: PaymentTerms.immediate,
            ),
          ),
        );
        final listed = okValue(await teachers.list(TeacherFilter(search: 'Live $_run')));
        expect(listed.items.single.paymentTerms, PaymentTerms.immediate);
        expect(okValue(await teachers.get(teacher.id)).schoolName, contains('Live'));
        step('teachers: create (with account), update, list, get');

        // -------------------------------------------------------------- 4. Products
        final images = ProductImages(
          ProductRepositoryImpl(api: api, cache: cache, listPath: '/api/admin/products'),
        );
        final adminProducts = AdminProductRepositoryImpl(api: api, cache: cache, images: images);
        final productReader = ProductRepositoryImpl(api: api, cache: cache, listPath: '/api/admin/products');
        final productId = okValue(
          await adminProducts.create(
            ProductDraft(teacherId: teacher.id, name: 'Live $_run Maths', priceText: '1200'),
          ),
        );
        final spareId = okValue(
          await adminProducts.create(
            ProductDraft(teacherId: teacher.id, name: 'Live $_run Spare', priceText: '300'),
          ),
        );
        _ok(
          'product update',
          await adminProducts.update(
            productId,
            ProductDraft(name: 'Live $_run Maths 3AS', priceText: '1200'),
          ),
        );
        _ok('cover upload', await adminProducts.setCover(productId, _png, 'cover.png'));
        _ok('cover read', await productReader.getImage(productId));
        _ok('cover delete', await adminProducts.removeCover(productId));
        _ok('product delete', await adminProducts.delete(spareId));
        final products = okValue(
          await productReader.watchProducts(ProductQuery(clientId: teacher.id), refresh: true).last,
        );
        expect(products.items.map((p) => p.id), [productId]);
        step('products: create, update, cover put/get/delete, delete, list by teacher');

        // -------------------------------------------------------------- 5. Orders
        final orders = AdminOrderRepositoryImpl(api);
        final orderReader = OrderRepositoryImpl(api);
        final maths = products.items.single;
        final placed = okValue(
          await orders.place(const OrderDraft().withClient(teacher.id).add(maths).add(maths)),
        );
        expect(placed.total, 2400);
        _ok('order revise', await orders.revise(placed.id, OrderDraft.of(placed).setQuantity(maths.id, 3)));
        _ok('order prepare', await orders.changeStatus(placed.id, OrderStatus.inPreparation, note: 'Live'));
        final order = okValue(await orderReader.getOrder(placed.id));
        expect(order.lines.single.quantity, 3);
        expect(order.status, OrderStatus.inPreparation);
        final orderList = okValue(
          await orders.list(OrderFilter(clientId: teacher.id, status: OrderStatus.inPreparation)),
        );
        expect(orderList.items.single.number, placed.number);
        step('orders: place for teacher, revise, status, get, list');

        // -------------------------------------------------------------- 6. Wallets
        final wallets = WalletRepositoryImpl(api);
        final deposit = okValue(
          await wallets.deposit(
            teacher.id,
            const DepositDraft(amount: 10000, method: PaymentMethod.cash, reference: 'Live'),
          ),
        );
        expect(deposit.receiptLabel, startsWith('REC-'));
        final withdrawal = okValue(
          await wallets.withdraw(teacher.id, const WithdrawalDraft(amount: 500, note: 'Live')),
        );
        _ok('void withdrawal', await wallets.voidTransaction(withdrawal.id, 'Live: by mistake'));
        expect(okValue(await wallets.get(teacher.id)).balance, 10000);
        final ledger = okValue(await wallets.transactions(TransactionFilter(clientId: teacher.id)));
        expect(ledger.items.length, 3);
        final receipt = okValue(await wallets.receipt(deposit.id));
        expect(String.fromCharCodes(receipt.take(4)), '%PDF');
        _ok('wallets list', await wallets.list(WalletFilter(search: 'Live $_run')));
        step('wallets: deposit, withdrawal, void, get, ledger, receipt, list');

        // -------------------------------------------------------------- 7. Invoices
        final invoices = InvoiceRepositoryImpl(api);
        final uninvoiced = okValue(await invoices.uninvoiced(teacher.id));
        expect(uninvoiced.single.quantity, 3);
        final issued = okValue(
          await invoices.issue(InvoiceDraft(clientId: teacher.id, available: uninvoiced).selectAll()),
        );
        expect(issued.summary.total, 3600);
        final partly = okValue(await invoices.settle(issued.id, amount: 600));
        expect(partly.summary.amountDue, 3000);
        final settlement = okValue(await wallets.settle(teacher.id));
        expect(settlement.paid, 3000);
        final invoice = okValue(await invoices.get(issued.id));
        expect(invoice.summary.paymentStatus, InvoicePaymentStatus.paid);
        final pdf = okValue(await invoices.pdf(issued.id));
        expect(String.fromCharCodes(pdf.take(4)), '%PDF');
        _ok('invoice list', await invoices.list(InvoiceFilter(clientId: teacher.id)));
        _ok('invoice void', await invoices.voidInvoice(issued.id, 'Live: test'));
        expect(okValue(await wallets.get(teacher.id)).balance, 10000, reason: 'voiding refunds the payments');
        step('invoices: uninvoiced, issue, settle, wallet settle, get, pdf, list, void');

        // -------------------------------------------------------------- 8. Debts
        final debts = DebtRepositoryImpl(api);
        final debt = okValue(
          await debts.create(DebtDraft(clientId: teacher.id, description: 'Live $_run ancien', amount: 1000)),
        );
        _ok('debt settle', await debts.settle(debt.id, amount: 100));
        final writtenOff = okValue(await debts.writeOff(debt.id, 'Live: geste'));
        expect(writtenOff.amountDue, 0);
        expect(okValue(await debts.get(debt.id)).amountWrittenOff, 900);
        _ok('debts overview', await debts.overview(DebtFilter(search: 'Live $_run', onlyOwing: false)));
        _ok('client debts', await debts.forClient(teacher.id, includeClosed: true));
        step('debts: create, settle, write-off, get, overview, per teacher');

        // -------------------------------------------------------------- Statement (teacher)
        final today = DateTime.now();
        final statement = okValue(
          await teachers.statement(teacher.id, from: DateTime(today.year), to: today),
        );
        expect(statement.totals.deposited, greaterThanOrEqualTo(10000));
        final statementPdf = okValue(
          await teachers.statementPdf(teacher.id, from: DateTime(today.year), to: today),
        );
        expect(String.fromCharCodes(statementPdf.take(4)), '%PDF');
        step('teachers: statement, statement pdf');

        // -------------------------------------------------------------- Order to the end
        _ok('order ready', await orders.changeStatus(placed.id, OrderStatus.ready));
        _ok('order delivered', await orders.changeStatus(placed.id, OrderStatus.delivered));
        step('orders: ready, delivered');

        // -------------------------------------------------------------- 9. Reports
        final reports = ReportRepositoryImpl(api);
        final period = ReportPeriod.thisMonth(today);
        expect(okValue(await reports.summary(period)).ordersPlaced, greaterThan(0));
        for (final group in SalesGroupBy.values) {
          _ok('sales by $group', await reports.sales(period, group));
        }
        step('reports: summary, sales by every grouping');

        // -------------------------------------------------------------- 10. Security
        final security = SecurityRepositoryImpl(api);
        final resources = okValue(await security.resources());
        expect(resources.map((r) => r.name), contains('Product'));
        final roleName = 'Live$_run';
        _ok('role create', await security.createRole(roleName, 'Live test role'));
        final matrix = okValue(await security.matrix(roleName));
        final edited = matrix.toggled('Product', ResourceAction.read);
        _ok('permissions', await security.setPermissions(roleName, edited.toGrants()));
        final roles = okValue(await security.roles());
        expect(roles.firstWhere((role) => role.name == roleName).grants.single.resource, 'Product');
        _ok(
          'user create',
          await security.createUser(
            UserDraft(userName: 'staff$_run', password: 'Staff-$_run-pass', roles: {roleName}),
          ),
        );
        final staff = okValue(await security.users()).firstWhere((user) => user.userName == 'staff$_run');
        _ok('user roles', await security.setUserRoles(staff.userId, {roleName, 'Admin'}));
        step('security: resources, roles, create role, matrix, permissions, users, create user, set roles');

        // -------------------------------------------------------------- Auth: change password, logout
        final staffApi = await _signedIn('staff$_run', 'Staff-$_run-pass');
        _ok(
          'change password',
          await staffApi.post(
            '/api/auth/change-password',
            data: {'currentPassword': 'Staff-$_run-pass', 'newPassword': 'Staff-$_run-new'},
            decode: ApiClient.ignoreBody,
          ),
        );
        // The new password works; then sign out that session.
        final pair = okValue(
          await ApiClient(Dio(BaseOptions(baseUrl: _baseUrl))).post(
            '/api/auth/login',
            data: {'userName': 'staff$_run', 'password': 'Staff-$_run-new'},
            decode: (json) => json! as Map<String, Object?>,
          ),
        );
        _ok(
          'logout',
          await ApiClient(Dio(BaseOptions(baseUrl: _baseUrl))).post(
            '/api/auth/logout',
            data: {'refreshToken': pair['refreshToken']},
            decode: ApiClient.ignoreBody,
          ),
        );
        step('auth: change password, sign in with it, logout');

        // -------------------------------------------------------------- Clean up the accounts
        _ok('user deactivate', await security.deactivateUser(staff.userId));
        _ok('teacher deactivate', await teachers.deactivate(teacher.id));
        step('security: deactivate user; teachers: deactivate');
      } finally {
        await settingsRepo.saveBilling(
          autoSettle: originalSettings.autoSettle,
          defaultPaymentTerms: originalSettings.defaultPaymentTerms,
        );
        // Printed for the report of the run.
        // ignore: avoid_print
        print('Live run $_run passed steps:\n- ${log.join('\n- ')}');
      }
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
