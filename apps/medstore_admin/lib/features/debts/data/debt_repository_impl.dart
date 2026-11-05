import 'package:medstore_core/medstore_core.dart';

import '../domain/debts.dart';

class DebtRepositoryImpl implements DebtRepository {
  const DebtRepositoryImpl(this._api);

  static const _path = '/api/admin/debts';

  final ApiClient _api;

  @override
  Future<Result<PagedList<DebtOverview>>> overview(DebtFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {
      if (filter.search.isNotEmpty) 'search': filter.search,
      'onlyOwing': filter.onlyOwing,
      'page': page,
      'pageSize': 50,
    },
    decode: (json) => PagedList.fromJson(json, _overview),
  );

  @override
  Future<Result<ClientDebts>> forClient(String clientId, {bool includeClosed = false}) => _api.get(
    '$_path/clients/$clientId',
    query: {if (includeClosed) 'includeClosed': true},
    decode: (raw) {
      final json = JsonMap.of(raw);
      return ClientDebts(totals: _overview(json['totals']), items: json.list('items', _item));
    },
  );

  @override
  Future<Result<Debt>> get(String id) => _api.get('$_path/$id', decode: debtFromJson);

  @override
  Future<Result<Debt>> create(DebtDraft draft) => _api.post(
    _path,
    data: {
      'clientId': draft.clientId,
      'description': draft.description.trim(),
      'amount': draft.amount,
      if (draft.dueDate != null) 'dueDate': apiDay(draft.dueDate!),
    },
    decode: debtFromJson,
  );

  @override
  Future<Result<Debt>> settle(String id, {num? amount}) =>
      _api.post('$_path/$id/settle', data: {'amount': amount}, decode: debtFromJson);

  @override
  Future<Result<Debt>> writeOff(String id, String reason) =>
      _api.post('$_path/$id/write-off', data: {'reason': reason}, decode: debtFromJson);

  static DebtOverview _overview(Object? raw) {
    final json = JsonMap.of(raw);
    return DebtOverview(
      clientId: json.string('clientId'),
      clientName: json.string('clientName'),
      phone: json.stringOrNull('phone'),
      overdueInvoices: json.money('overdueInvoices'),
      upcomingInvoices: json.money('upcomingInvoices'),
      openDebts: json.money('openDebts'),
      overdue: json.money('overdue'),
      totalOwed: json.money('totalOwed'),
      walletBalance: json.money('walletBalance'),
      oldestDueDate: json.dayOrNull('oldestDueDate'),
    );
  }

  static DebtItem _item(Object? raw) {
    final json = JsonMap.of(raw);
    return DebtItem(
      kind: DebtItemKind.fromApi(json.stringOrNull('kind')),
      id: json.string('id'),
      label: json.string('label'),
      date: json.day('date'),
      dueDate: json.day('dueDate'),
      amount: json.money('amount'),
      amountPaid: json.money('amountPaid'),
      amountDue: json.money('amountDue'),
      isOverdue: json.boolean('isOverdue'),
    );
  }

  static Debt debtFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return Debt(
      id: json.string('id'),
      clientId: json.string('clientId'),
      clientName: json.stringOrNull('clientName'),
      description: json.string('description'),
      amount: json.money('amount'),
      amountPaid: json.money('amountPaid'),
      amountDue: json.money('amountDue'),
      amountWrittenOff: json.money('amountWrittenOff'),
      dueDate: json.day('dueDate'),
      createdAt: json.instant('createdAt'),
      writtenOffAt: json.instantOrNull('writtenOffAt'),
      writeOffReason: json.stringOrNull('writeOffReason'),
      isOverdue: json.boolean('isOverdue'),
    );
  }
}
