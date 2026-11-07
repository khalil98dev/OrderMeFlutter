import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/schools/data/school_repository_impl.dart';
import 'package:medstore_admin/features/schools/domain/school.dart';
import 'package:medstore_admin/features/teachers/data/teacher_repository_impl.dart';
import 'package:medstore_admin/features/teachers/domain/teacher.dart';
import 'package:medstore_admin/features/wallets/domain/wallet.dart';
import 'package:medstore_core/medstore_core.dart';

import '../helpers/fake_api.dart';

Map<String, Object?> _teacherJson({String id = 't1', String? terms = 'EndOfMonth'}) => {
  'id': id,
  'userId': 'u1',
  'userName': 'amina',
  'fullName': 'Amina Benali',
  'phone': '0550000000',
  'schoolId': 's1',
  'schoolName': 'Lycée Ibn Khaldoun',
  'paymentTerms': ?terms,
  'isActive': true,
  'createdAt': '2026-11-04T10:00:00+00:00',
};

void main() {
  group('TeacherRepositoryImpl', () {
    late FakeApi api;
    late TeacherRepositoryImpl repository;

    setUp(() {
      api = FakeApi();
      repository = TeacherRepositoryImpl(api.client);
    });

    test('lists with the filters the API knows, leaving empty ones out', () async {
      api.reply = (_) => FakeReply(paged([_teacherJson()]));

      final page = okValue(
        await repository.list(const TeacherFilter(search: 'ami', schoolId: 's1'), page: 2),
      );

      expect(api.last.path, '/api/admin/clients');
      expect(api.last.queryParameters, {
        'search': 'ami',
        'schoolId': 's1',
        'isActive': true,
        'page': 2,
        'pageSize': 50,
      });
      expect(page.items.single.fullName, 'Amina Benali');
      expect(page.items.single.paymentTerms, PaymentTerms.endOfMonth);
    });

    test('a hidden payment terms field reads as null', () async {
      api.reply = (_) => FakeReply(_teacherJson(terms: null));
      expect(okValue(await repository.get('t1')).paymentTerms, isNull);
    });

    test('creates the teacher with their sign-in account; default terms are left out', () async {
      api.reply = (_) => FakeReply(_teacherJson(), status: 201);

      await repository.create(
        const TeacherDraft(fullName: ' Amina ', userName: 'amina', password: 'secret123', phone: ''),
      );

      expect(api.last.method, 'POST');
      expect(api.lastBody, {
        'userName': 'amina',
        'password': 'secret123',
        'email': null,
        'fullName': 'Amina',
        'phone': null,
        'subject': null,
        'schoolId': null,
      });
    });

    test('updates, deactivates, and reads the statement for a period', () async {
      await repository.update('t1', const TeacherDraft(fullName: 'A', paymentTerms: PaymentTerms.immediate));
      expect(api.last.method, 'PUT');
      expect((api.lastBody! as Map)['paymentTerms'], 'Immediate');

      await repository.deactivate('t1');
      expect(api.last.path, '/api/admin/clients/t1/deactivate');

      await repository.setPassword('t1', 'Nouveau-2026');
      expect(api.last.method, 'POST');
      expect(api.last.path, '/api/admin/clients/t1/password');
      expect(api.lastBody, {'newPassword': 'Nouveau-2026'});

      api.reply = (_) => const FakeReply({
        'clientId': 't1',
        'clientName': 'Amina',
        'paymentTerms': 'EndOfMonth',
        'from': '2026-01-01',
        'to': '2026-11-05',
        'generatedOn': '2026-11-05',
        'invoices': [
          {
            'id': 'i1',
            'label': 'INV-000001',
            'issueDate': '2026-11-01',
            'dueDate': '2026-11-30',
            'total': 1200,
            'amountPaid': 200,
            'amountDue': 1000,
            'isVoided': false,
            'isOverdue': false,
          },
        ],
        'movements': [
          {
            'occurredAt': '2026-11-02T08:00:00+00:00',
            'type': 'Deposit',
            'amount': 5000,
            'balanceAfter': 5000,
            'isVoided': false,
          },
        ],
        'openDebts': <Object?>[],
        'totals': {
          'invoiced': 1200,
          'deposited': 5000,
          'paidFromWallet': 200,
          'owedNow': 1000,
          'overdueNow': 0,
          'walletBalanceNow': 4800,
        },
      });
      final statement = okValue(
        await repository.statement('t1', from: DateTime(2026), to: DateTime(2026, 11, 5)),
      );

      expect(api.last.queryParameters, {'from': '2026-01-01', 'to': '2026-11-05'});
      expect(statement.invoices.single.amountDue, 1000);
      expect(statement.movements.single.type, WalletTransactionType.deposit);
      expect(statement.totals.walletBalanceNow, 4800);
    });

    test('downloads the statement PDF as bytes', () async {
      api.reply = (_) => FakeReply(Uint8List.fromList([37, 80, 68, 70]));
      final bytes = okValue(await repository.statementPdf('t1'));
      expect(api.last.path, '/api/admin/clients/t1/statement/pdf');
      expect(bytes, [37, 80, 68, 70]);
    });

    test('a refused create carries the API rule codes', () async {
      api.reply = (_) => FakeReply(
        problem(
          400,
          errors: {
            'Client.PhoneInvalid': ['bad'],
          },
        ),
        status: 400,
      );
      final failure = errOf(
        await repository.create(const TeacherDraft(fullName: 'A', userName: 'a', password: 'x')),
      );
      expect((failure as ValidationFailure).errors.keys, ['Client.PhoneInvalid']);
    });
  });

  group('SchoolRepositoryImpl', () {
    late FakeApi api;
    late SchoolRepositoryImpl repository;
    const schoolJson = {
      'id': 's1',
      'name': 'Lycée Ibn Khaldoun',
      'wilayaCode': 16,
      'city': 'Alger',
      'level': 'Secondary',
      'type': 'Public',
    };

    setUp(() {
      api = FakeApi();
      repository = SchoolRepositoryImpl(
        api: api.client,
        cache: HybridCache(memory: MemoryStore(), disk: MemoryStore()),
      );
    });

    test('lists a plain array and keeps it in the cache', () async {
      api.reply = (_) => const FakeReply([schoolJson]);

      final first = okValue(await repository.list(const SchoolFilter(wilayaCode: 16)));
      await repository.list(const SchoolFilter(wilayaCode: 16));

      expect(first.single.level, SchoolLevel.secondary);
      expect(api.requests, hasLength(1), reason: 'the second list comes from the cache');
      expect(api.last.queryParameters, {'wilayaCode': 16});
    });

    test('a change drops the cached lists', () async {
      api.reply = (request) =>
          request.method == 'GET' ? const FakeReply([schoolJson]) : const FakeReply.noContent();
      await repository.list(const SchoolFilter());

      await repository.update(
        's1',
        const SchoolDraft(name: 'X', wilayaText: '31', level: SchoolLevel.middle),
      );
      expect(api.lastBody, {
        'name': 'X',
        'wilayaCode': 31,
        'city': null,
        'level': 'Middle',
        'type': 'Public',
      });

      await repository.list(const SchoolFilter());
      expect(api.requests.where((r) => r.method == 'GET'), hasLength(2));
    });
  });

  group('drafts', () {
    test('a school needs a name and a wilaya between 1 and 58', () {
      expect(const SchoolDraft(name: '', wilayaText: '59').validate(), {
        SchoolField.name,
        SchoolField.wilaya,
      });
      expect(const SchoolDraft(name: 'A', wilayaText: '58').validate(), isEmpty);
    });

    test('a new teacher needs a user name and an 8-character password; an edit does not', () {
      const draft = TeacherDraft(fullName: 'A', userName: '', password: 'short');
      expect(draft.validate(isNew: true), {TeacherField.userName, TeacherField.password});
      expect(draft.validate(isNew: false), isEmpty);
    });
  });
}
