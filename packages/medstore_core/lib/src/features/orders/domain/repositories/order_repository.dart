import '../../../../core/result/result.dart';
import '../entities/order.dart';

/// Reading one order. The teacher gets only their own (404 otherwise); the team gets any.
abstract interface class OrderRepository {
  /// `GET /api/orders/{id}`: the order with its lines and timeline, always fresh.
  Future<Result<Order>> getOrder(String id);
}
