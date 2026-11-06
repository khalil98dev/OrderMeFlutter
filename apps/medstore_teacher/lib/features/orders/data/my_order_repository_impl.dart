import 'package:medstore_core/medstore_core.dart';

import '../domain/my_orders.dart';

class MyOrderRepositoryImpl implements MyOrderRepository {
  const MyOrderRepositoryImpl(this._api);

  static const _path = '/api/orders';

  final ApiClient _api;

  @override
  Future<Result<PagedList<OrderSummary>>> list(MyOrdersFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {if (filter.status case final status?) 'status': status.apiName, 'page': page, 'pageSize': 20},
    decode: (json) => PagedList.fromJson(json, OrderModel.summaryFromJson),
  );

  @override
  Future<Result<Order>> place({required List<NewOrderLine> lines, String? notes}) => _api.post(
    _path,
    data: {
      'notes': notes,
      'lines': [
        for (final line in lines) {'productId': line.productId, 'quantity': line.quantity},
      ],
    },
    decode: OrderModel.fromJson,
  );

  @override
  Future<Result<void>> cancel(String orderId, {String? reason}) =>
      _api.post('$_path/$orderId/cancel', data: {'reason': reason}, decode: ApiClient.ignoreBody);

  @override
  Future<Result<void>> confirmDelivery(String orderId) =>
      _api.post('$_path/$orderId/confirm-delivery', decode: ApiClient.ignoreBody);
}
