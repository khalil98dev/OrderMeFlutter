import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/forms/form_values.dart';
import '../../wallets/data/wallet_models.dart';
import '../domain/statement.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  const TeacherRepositoryImpl(this._api);

  static const _path = '/api/admin/clients';

  final ApiClient _api;

  @override
  Future<Result<PagedList<Teacher>>> list(TeacherFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {
      if (filter.search.isNotEmpty) 'search': filter.search,
      if (filter.schoolId != null) 'schoolId': filter.schoolId,
      if (filter.isActive != null) 'isActive': filter.isActive,
      'page': page,
      'pageSize': 50,
    },
    decode: (json) => PagedList.fromJson(json, teacherFromJson),
  );

  @override
  Future<Result<Teacher>> get(String id) => _api.get('$_path/$id', decode: teacherFromJson);

  @override
  Future<Result<Teacher>> create(TeacherDraft draft) => _api.post(
    _path,
    data: {
      'userName': draft.userName.trim(),
      'password': draft.password,
      'email': optionalText(draft.email),
      ..._profile(draft),
      if (draft.paymentTerms != null) 'paymentTerms': draft.paymentTerms!.apiName,
    },
    decode: teacherFromJson,
  );

  @override
  Future<Result<void>> update(String id, TeacherDraft draft) => _api.put(
    '$_path/$id',
    // The update requires terms; an unreadable value (null) keeps the default rather than failing.
    data: {..._profile(draft), 'paymentTerms': (draft.paymentTerms ?? PaymentTerms.immediate).apiName},
    decode: ApiClient.ignoreBody,
  );

  @override
  Future<Result<void>> deactivate(String id) =>
      _api.post('$_path/$id/deactivate', decode: ApiClient.ignoreBody);

  @override
  Future<Result<void>> setPassword(String id, String newPassword) =>
      _api.post('$_path/$id/password', data: {'newPassword': newPassword}, decode: ApiClient.ignoreBody);

  @override
  Future<Result<Statement>> statement(String id, {DateTime? from, DateTime? to}) =>
      _api.get('$_path/$id/statement', query: _period(from, to), decode: statementFromJson);

  @override
  Future<Result<Uint8List>> statementPdf(String id, {DateTime? from, DateTime? to}) => _api.get(
    '$_path/$id/statement/pdf',
    query: _period(from, to),
    options: Options(responseType: ResponseType.bytes),
    decode: (bytes) => Uint8List.fromList(bytes! as List<int>),
  );

  static Map<String, Object?> _period(DateTime? from, DateTime? to) => {
    if (from != null) 'from': apiDay(from),
    if (to != null) 'to': apiDay(to),
  };

  static Map<String, Object?> _profile(TeacherDraft draft) => {
    'fullName': draft.fullName.trim(),
    'phone': optionalText(draft.phone),
    'subject': optionalText(draft.subject),
    'schoolId': draft.schoolId,
  };

  static Teacher teacherFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return Teacher(
      id: json.string('id'),
      userId: json.string('userId'),
      userName: json.stringOrNull('userName'),
      fullName: json.string('fullName'),
      phone: json.stringOrNull('phone'),
      subject: json.stringOrNull('subject'),
      schoolId: json.stringOrNull('schoolId'),
      schoolName: json.stringOrNull('schoolName'),
      paymentTerms: PaymentTerms.fromApiOrNull(json.stringOrNull('paymentTerms')),
      isActive: json.boolean('isActive'),
      createdAt: json.instant('createdAt'),
    );
  }

  static Statement statementFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    final totals = json.object('totals');
    return Statement(
      clientId: json.string('clientId'),
      clientName: json.string('clientName'),
      phone: json.stringOrNull('phone'),
      schoolName: json.stringOrNull('schoolName'),
      paymentTerms: PaymentTerms.fromApi(json.stringOrNull('paymentTerms')),
      from: json.day('from'),
      to: json.day('to'),
      generatedOn: json.day('generatedOn'),
      invoices: json.list('invoices', (raw) {
        final invoice = JsonMap.of(raw);
        return StatementInvoice(
          id: invoice.string('id'),
          label: invoice.string('label'),
          issueDate: invoice.day('issueDate'),
          dueDate: invoice.day('dueDate'),
          total: invoice.money('total'),
          amountPaid: invoice.money('amountPaid'),
          amountDue: invoice.money('amountDue'),
          isVoided: invoice.boolean('isVoided'),
          isOverdue: invoice.boolean('isOverdue'),
        );
      }),
      movements: json.list('movements', (raw) {
        final movement = JsonMap.of(raw);
        return StatementMovement(
          occurredAt: movement.instant('occurredAt'),
          type: WalletModels.typeFromApi(movement.stringOrNull('type')),
          amount: movement.money('amount'),
          balanceAfter: movement.money('balanceAfter'),
          receiptLabel: movement.stringOrNull('receiptLabel'),
          note: movement.stringOrNull('note'),
          isVoided: movement.boolean('isVoided'),
        );
      }),
      openDebts: json.list('openDebts', (raw) {
        final debt = JsonMap.of(raw);
        return StatementDebt(
          id: debt.string('id'),
          description: debt.string('description'),
          dueDate: debt.day('dueDate'),
          amount: debt.money('amount'),
          amountDue: debt.money('amountDue'),
          isOverdue: debt.boolean('isOverdue'),
        );
      }),
      totals: StatementTotals(
        invoiced: totals.money('invoiced'),
        deposited: totals.money('deposited'),
        paidFromWallet: totals.money('paidFromWallet'),
        owedNow: totals.money('owedNow'),
        overdueNow: totals.money('overdueNow'),
        walletBalanceNow: totals.money('walletBalanceNow'),
      ),
    );
  }
}
