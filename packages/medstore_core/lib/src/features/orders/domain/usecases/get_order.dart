import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// One order with its lines and timeline.
class GetOrder implements UseCase<Order, String> {
  const GetOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(String orderId) => _repository.getOrder(orderId);
}
