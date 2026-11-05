import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/reports/data/report_repository_impl.dart';
import 'package:medstore_admin/features/reports/domain/reports.dart';
import 'package:medstore_admin/features/security/data/security_repository_impl.dart';
import 'package:medstore_admin/features/security/domain/security.dart';
import 'package:medstore_admin/features/settings/data/settings_repository_impl.dart';
import 'package:medstore_core/medstore_core.dart';

import '../helpers/fake_api.dart';

void main() {
  late FakeApi api;
  setUp(() => api = FakeApi());

  test('ReportRepositoryImpl reads the summary and sales for a period', () async {
    final repository = ReportRepositoryImpl(api.client);
    api.reply = (_) => const FakeReply({
      'from': '2026-11-01',
      'to': '2026-11-05',
      'ordersPlaced': 3,
      'copiesOrdered': 40,
      'amountOrdered': 48000,
      'ordersByStatus': {'pending': 1, 'inPreparation': 1, 'ready': 0, 'delivered': 1, 'cancelled': 0},
      'invoicesIssued': 1,
      'amountInvoiced': 12000,
      'deposits': 2,
      'amountDeposited': 20000,
      'amountPaidFromWallets': 12000,
      'newTeachers': 1,
      'activeTeachers': 4,
      'owedNow': 3000,
      'overdueNow': 0,
      'heldInWalletsNow': 8000,
    });
    final period = ReportPeriod(from: DateTime(2026, 11), to: DateTime(2026, 11, 5));
    final summary = okValue(await repository.summary(period));
    expect(api.last.path, '/api/admin/reports/summary');
    expect(api.last.queryParameters, {'from': '2026-11-01', 'to': '2026-11-05'});
    expect(summary.ordersByStatus[OrderStatus.delivered], 1);

    api.reply = (_) => const FakeReply({
      'from': '2026-11-01',
      'to': '2026-11-05',
      'groupBy': 'Wilaya',
      'rows': [
        {'key': '16', 'label': 'Alger', 'orders': 3, 'copies': 40, 'amount': 48000},
      ],
      'orders': 3,
      'copies': 40,
      'amount': 48000,
    });
    final sales = okValue(await repository.sales(period, SalesGroupBy.wilaya));
    expect(api.last.queryParameters['groupBy'], 'Wilaya');
    expect(sales.rows.single.label, 'Alger');
  });

  test('SettingsRepositoryImpl reads and saves billing settings', () async {
    final repository = SettingsRepositoryImpl(api.client);
    api.reply = (_) => const FakeReply({'autoSettle': true, 'defaultPaymentTerms': 'EndOfMonth'});
    final settings = okValue(await repository.billing());
    expect(settings.defaultPaymentTerms, PaymentTerms.endOfMonth);

    await repository.saveBilling(autoSettle: false, defaultPaymentTerms: PaymentTerms.immediate);
    expect(api.last.method, 'PUT');
    expect(api.lastBody, {'autoSettle': false, 'defaultPaymentTerms': 'Immediate'});
  });

  group('SecurityRepositoryImpl', () {
    late SecurityRepositoryImpl repository;
    setUp(() => repository = SecurityRepositoryImpl(api.client));

    test('reads resources, roles and a matrix (flags as lists or "Read, Set")', () async {
      api.reply = (_) => const FakeReply([
        {
          'name': 'Product',
          'actions': ['Create', 'Read', 'Set', 'Delete'],
          'fields': [
            {
              'name': 'Price',
              'actions': ['Read', 'Set'],
            },
          ],
        },
      ]);
      final resources = okValue(await repository.resources());
      expect(resources.single.fields['Price'], {FieldAction.read, FieldAction.set});

      api.reply = (_) => const FakeReply([
        {
          'name': 'Client',
          'description': 'Enseignants',
          'grants': [
            {
              'resource': 'Product',
              'actions': 'Read',
              'fields': {'Price': 'Read'},
            },
          ],
        },
      ]);
      final roles = okValue(await repository.roles());
      expect(roles.single.grants.single.actions, {ResourceAction.read});

      api.reply = (_) => const FakeReply({
        'role': 'Client',
        'description': 'Enseignants',
        'resources': [
          {
            'name': 'Product',
            'available': ['Create', 'Read', 'Set', 'Delete'],
            'granted': ['Read'],
            'fields': [
              {
                'name': 'Price',
                'available': ['Read', 'Set'],
                'granted': <String>[],
              },
            ],
          },
        ],
      });
      final matrix = okValue(await repository.matrix('Client'));
      expect(api.last.path, '/api/admin/security/roles/Client/matrix');
      expect(matrix.resources.single.granted, {ResourceAction.read});
    });

    test('saves grants as flag strings, one per resource with anything ticked', () async {
      await repository.setPermissions('Client', const [
        Grant(
          resource: 'Product',
          actions: {ResourceAction.set, ResourceAction.read},
          fields: {
            'Price': {FieldAction.read},
          },
        ),
      ]);
      expect(api.last.path, '/api/admin/roles/Client/permissions');
      expect(api.lastBody, [
        {
          'resource': 'Product',
          'actions': 'Read, Set',
          'fields': {'Price': 'Read'},
        },
      ]);
    });

    test('creates roles and users, sets roles, deactivates', () async {
      await repository.createRole('Magasinier', 'Prépare les commandes');
      expect(api.lastBody, {'name': 'Magasinier', 'description': 'Prépare les commandes'});

      await repository.createUser(
        const UserDraft(userName: 'karim', password: 'secret123', roles: {'Magasinier'}),
      );
      expect(api.lastBody, {
        'userName': 'karim',
        'email': null,
        'password': 'secret123',
        'roles': ['Magasinier'],
      });

      await repository.setUserRoles('u1', {'Admin'});
      expect(api.last.path, '/api/admin/users/u1/roles');
      expect(api.lastBody, {
        'roles': ['Admin'],
      });

      await repository.deactivateUser('u1');
      expect(api.last.path, '/api/admin/users/u1/deactivate');

      api.reply = (_) => const FakeReply([
        {
          'userId': 'u1',
          'userName': 'amina',
          'isActive': true,
          'roles': ['Client'],
        },
      ]);
      expect(okValue(await repository.users()).single.isTeacher, isTrue);
    });
  });

  group('flags', () {
    test('"All" and "None" read as every action and none', () {
      expect(parseResourceActions('All'), ResourceAction.values.toSet());
      expect(parseResourceActions('None'), isEmpty);
      expect(formatFlags(<ResourceAction>{}, ResourceAction.values, (a) => a.apiName), 'None');
    });
  });
}
