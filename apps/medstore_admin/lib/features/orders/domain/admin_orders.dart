import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// What the orders list shows. `to` is the last day included.
final class OrderFilter extends Equatable {
  const OrderFilter({this.clientId, this.clientName, this.status, this.number, this.from, this.to});

  final String? clientId;

  /// Shown in the teacher filter; not sent.
  final String? clientName;
  final OrderStatus? status;
  final int? number;
  final DateTime? from;
  final DateTime? to;

  OrderFilter copyWith({
    (String, String)? Function()? client,
    OrderStatus? Function()? status,
    int? Function()? number,
    DateTime? Function()? from,
    DateTime? Function()? to,
  }) {
    final teacher = client == null ? null : client();
    return OrderFilter(
      clientId: client == null ? clientId : teacher?.$1,
      clientName: client == null ? clientName : teacher?.$2,
      status: status == null ? this.status : status(),
      number: number == null ? this.number : number(),
      from: from == null ? this.from : from(),
      to: to == null ? this.to : to(),
    );
  }

  @override
  List<Object?> get props => [clientId, status, number, from, to];
}

/// One line being edited: a product and how many copies.
final class DraftLine extends Equatable {
  const DraftLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unitPrice,
  });

  final String productId;
  final String productName;

  /// For the running total on screen. The server sets the real price (a revision keeps the old one).
  final num? unitPrice;
  final int quantity;

  DraftLine withQuantity(int value) =>
      DraftLine(productId: productId, productName: productName, unitPrice: unitPrice, quantity: value);

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity];
}

enum OrderDraftProblem { teacherRequired, linesRequired, quantityInvalid }

/// A new order for a teacher, or the new lines of an existing one (the whole list is sent).
final class OrderDraft extends Equatable {
  const OrderDraft({this.clientId, this.lines = const [], this.notes = ''});

  factory OrderDraft.of(Order order) => OrderDraft(
    clientId: order.clientId,
    notes: order.notes ?? '',
    lines: [
      for (final line in order.lines)
        DraftLine(
          productId: line.productId,
          productName: line.productName,
          unitPrice: line.unitPrice,
          quantity: line.quantity,
        ),
    ],
  );

  /// The server's bounds for one line.
  static const maxQuantity = 10000;

  final String? clientId;
  final List<DraftLine> lines;
  final String notes;

  num get total => lines.fold<num>(0, (sum, line) => sum + (line.unitPrice ?? 0) * line.quantity);

  /// Adds a product, or one more copy when it is already there (each product once per order).
  OrderDraft add(Product product) {
    final index = lines.indexWhere((line) => line.productId == product.id);
    if (index >= 0) return setQuantity(product.id, lines[index].quantity + 1);
    return _copy(
      lines: [
        ...lines,
        DraftLine(productId: product.id, productName: product.name, unitPrice: product.price, quantity: 1),
      ],
    );
  }

  OrderDraft setQuantity(String productId, int quantity) => _copy(
    lines: [for (final line in lines) line.productId == productId ? line.withQuantity(quantity) : line],
  );

  OrderDraft remove(String productId) => _copy(
    lines: [
      for (final line in lines)
        if (line.productId != productId) line,
    ],
  );

  /// Changing the teacher empties the lines: products belong to one teacher.
  OrderDraft withClient(String? value) => OrderDraft(clientId: value, notes: notes);

  OrderDraft withNotes(String value) => _copy(notes: value);

  OrderDraft _copy({List<DraftLine>? lines, String? notes}) =>
      OrderDraft(clientId: clientId, lines: lines ?? this.lines, notes: notes ?? this.notes);

  Set<OrderDraftProblem> validate() => {
    if (clientId == null) OrderDraftProblem.teacherRequired,
    if (lines.isEmpty) OrderDraftProblem.linesRequired,
    if (lines.any((line) => line.quantity < 1 || line.quantity > maxQuantity))
      OrderDraftProblem.quantityInvalid,
  };

  @override
  List<Object?> get props => [clientId, lines, notes];
}

/// What a move did. Marking an order Ready issues its invoice for every copy not yet invoiced: the
/// wallet pays what it can, and [amountDue] is left as the teacher's debt until they pay at the counter.
final class StatusChangeOutcome extends Equatable {
  const StatusChangeOutcome({
    this.invoiceId,
    this.invoiceLabel,
    this.invoiceTotal,
    this.paidFromWallet,
    this.amountDue,
  });

  final String? invoiceId;

  /// "INV-000042".
  final String? invoiceLabel;
  final num? invoiceTotal;
  final num? paidFromWallet;
  final num? amountDue;

  bool get issuedInvoice => invoiceId != null;

  @override
  List<Object?> get props => [invoiceId, invoiceLabel, invoiceTotal, paidFromWallet, amountDue];
}

/// `/api/admin/orders`. One order with its lines is read through the shared `GetOrder`.
abstract interface class AdminOrderRepository {
  /// Newest first.
  Future<Result<PagedList<OrderSummary>>> list(OrderFilter filter, {int page = 1});

  /// An order taken on a teacher's behalf.
  Future<Result<Order>> place(OrderDraft draft);

  /// While Pending or InPreparation: replaces the notes and every line.
  Future<Result<void>> revise(String orderId, OrderDraft draft);

  /// A move allowed by the order's rules; any other answers 409. Ready issues the order's invoice.
  Future<Result<StatusChangeOutcome>> changeStatus(String orderId, OrderStatus status, {String? note});
}

class ListOrders {
  const ListOrders(this._repository);

  final AdminOrderRepository _repository;

  Future<Result<PagedList<OrderSummary>>> call(OrderFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

class PlaceOrder implements UseCase<Order, OrderDraft> {
  const PlaceOrder(this._repository);

  final AdminOrderRepository _repository;

  @override
  Future<Result<Order>> call(OrderDraft draft) => _repository.place(draft);
}

final class ReviseOrderParams {
  const ReviseOrderParams(this.orderId, this.draft);

  final String orderId;
  final OrderDraft draft;
}

class ReviseOrder implements UseCase<void, ReviseOrderParams> {
  const ReviseOrder(this._repository);

  final AdminOrderRepository _repository;

  @override
  Future<Result<void>> call(ReviseOrderParams params) => _repository.revise(params.orderId, params.draft);
}

final class ChangeOrderStatusParams {
  const ChangeOrderStatusParams(this.orderId, this.status, {this.note});

  final String orderId;
  final OrderStatus status;
  final String? note;
}

class ChangeOrderStatus implements UseCase<StatusChangeOutcome, ChangeOrderStatusParams> {
  const ChangeOrderStatus(this._repository);

  final AdminOrderRepository _repository;

  @override
  Future<Result<StatusChangeOutcome>> call(ChangeOrderStatusParams params) =>
      _repository.changeStatus(params.orderId, params.status, note: params.note);
}
