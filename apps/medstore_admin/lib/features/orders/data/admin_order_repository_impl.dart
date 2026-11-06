import 'package:medstore_core/medstore_core.dart';

import '../../../app/forms/form_values.dart';
import '../domain/admin_orders.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  const AdminOrderRepositoryImpl(this._api);

  static const _path = '/api/admin/orders';

  final ApiClient _api;

  @override
  Future<Result<PagedList<OrderSummary>>> list(OrderFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {
      if (filter.clientId != null) 'clientId': filter.clientId,
      if (filter.status != null) 'status': filter.status!.apiName,
      if (filter.number != null) 'number': filter.number,
      if (filter.from != null) 'from': apiDay(filter.from!),
      // The API's "to" is exclusive; the filter's is the last day shown.
      if (filter.to != null) 'to': apiDay(filter.to!.add(const Duration(days: 1))),
      'page': page,
      'pageSize': 50,
    },
    decode: (json) => PagedList.fromJson(json, OrderModel.summaryFromJson),
  );

  @override
  Future<Result<Order>> place(OrderDraft draft) =>
      _api.post(_path, data: {'clientId': draft.clientId, ..._body(draft)}, decode: OrderModel.fromJson);

  @override
  Future<Result<void>> revise(String orderId, OrderDraft draft) =>
      _api.put('$_path/$orderId', data: _body(draft), decode: ApiClient.ignoreBody);

  @override
  Future<Result<StatusChangeOutcome>> changeStatus(String orderId, OrderStatus status, {String? note}) =>
      _api.post(
        '$_path/$orderId/status',
        data: {'status': status.apiName, 'note': note == null ? null : optionalText(note)},
        decode: outcomeFromJson,
      );

  /// Tolerates an empty answer (an older API answered 204): nothing was issued.
  static StatusChangeOutcome outcomeFromJson(Object? raw) {
    if (raw is! Map<String, Object?>) return const StatusChangeOutcome();
    final json = JsonMap.of(raw);
    return StatusChangeOutcome(
      invoiceId: json.stringOrNull('invoiceId'),
      invoiceLabel: json.stringOrNull('invoiceLabel'),
      invoiceTotal: json.moneyOrNull('invoiceTotal'),
      paidFromWallet: json.moneyOrNull('paidFromWallet'),
      amountDue: json.moneyOrNull('amountDue'),
    );
  }

  static Map<String, Object?> _body(OrderDraft draft) => {
    'notes': optionalText(draft.notes),
    'lines': [
      for (final line in draft.lines) {'productId': line.productId, 'quantity': line.quantity},
    ],
  };
}
