import '../../../core/network/api_client.dart';
import '../../../core/result/result.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/order_repository.dart';
import 'order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<Order>> getOrder(String id) => _api.get('/api/orders/$id', decode: OrderModel.fromJson);
}
