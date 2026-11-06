import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// Which of the teacher's orders to list. Null status: all of them.
final class MyOrdersFilter extends Equatable {
  const MyOrdersFilter({this.status});

  final OrderStatus? status;

  @override
  List<Object?> get props => [status];
}

/// One product of a new order. The server takes the price from the product, never from the app.
final class NewOrderLine extends Equatable {
  const NewOrderLine({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

/// The teacher's own orders (`/api/orders`). Another teacher's order answers 404.
abstract interface class MyOrderRepository {
  Future<Result<PagedList<OrderSummary>>> list(MyOrdersFilter filter, {int page = 1});

  /// `POST /api/orders`: the new order, in status pending.
  Future<Result<Order>> place({required List<NewOrderLine> lines, String? notes});

  /// Only while the order is pending.
  Future<Result<void>> cancel(String orderId, {String? reason});

  /// Once the order is ready: the teacher received it.
  Future<Result<void>> confirmDelivery(String orderId);
}

class ListMyOrders {
  const ListMyOrders(this._repository);

  final MyOrderRepository _repository;

  Future<Result<PagedList<OrderSummary>>> call(MyOrdersFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

final class PlaceOrderParams extends Equatable {
  const PlaceOrderParams({required this.lines, this.notes});

  final List<NewOrderLine> lines;
  final String? notes;

  @override
  List<Object?> get props => [lines, notes];
}

class PlaceOrder implements UseCase<Order, PlaceOrderParams> {
  const PlaceOrder(this._repository);

  final MyOrderRepository _repository;

  @override
  Future<Result<Order>> call(PlaceOrderParams params) {
    final notes = params.notes?.trim();
    return _repository.place(lines: params.lines, notes: notes == null || notes.isEmpty ? null : notes);
  }
}

class CancelMyOrder implements UseCase<void, String> {
  const CancelMyOrder(this._repository);

  final MyOrderRepository _repository;

  @override
  Future<Result<void>> call(String orderId) => _repository.cancel(orderId);
}

class ConfirmDelivery implements UseCase<void, String> {
  const ConfirmDelivery(this._repository);

  final MyOrderRepository _repository;

  @override
  Future<Result<void>> call(String orderId) => _repository.confirmDelivery(orderId);
}
