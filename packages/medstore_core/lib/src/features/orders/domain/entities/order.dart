import 'package:equatable/equatable.dart';

/// Where an order is. Moves: pending → inPreparation → ready → delivered, or cancelled
/// (by the teacher only while pending; by the team until ready, with a note once preparation started).
enum OrderStatus {
  pending('Pending'),
  inPreparation('InPreparation'),
  ready('Ready'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.apiName);

  final String apiName;

  static OrderStatus fromApi(String? value) =>
      values.firstWhere((status) => status.apiName == value, orElse: () => pending);

  /// The moves the team may make from here (`Order.Transitions` on the server). Others answer 409.
  List<OrderStatus> get staffMoves => switch (this) {
    pending => const [inPreparation, cancelled],
    inPreparation => const [ready, cancelled],
    ready => const [delivered, cancelled],
    delivered || cancelled => const [],
  };

  /// The team must give a reason to cancel once preparation started.
  bool get cancelNeedsNote => this == inPreparation || this == ready;

  /// The team may still change the lines.
  bool get staffCanRevise => this == pending || this == inPreparation;
}

/// Who acted on an order.
enum OrderActor {
  client('Client'),
  staff('Staff');

  const OrderActor(this.apiName);

  final String apiName;

  static OrderActor fromApi(String? value) =>
      values.firstWhere((actor) => actor.apiName == value, orElse: () => staff);
}

/// A row in an order list.
final class OrderSummary extends Equatable {
  const OrderSummary({
    required this.id,
    required this.number,
    required this.clientId,
    required this.status,
    required this.total,
    required this.lineCount,
    required this.totalQuantity,
    required this.placedAt,
    this.clientName,
    this.updatedAt,
  });

  final String id;
  final int number;
  final String clientId;
  final String? clientName;
  final OrderStatus status;
  final num total;
  final int lineCount;
  final int totalQuantity;
  final DateTime placedAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    number,
    clientId,
    clientName,
    status,
    total,
    lineCount,
    totalQuantity,
    placedAt,
    updatedAt,
  ];
}

/// Copies of one product on an order, at the price of the day it was ordered.
final class OrderLine extends Equatable {
  const OrderLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.productCode,
  });

  final String id;
  final String productId;
  final String productName;
  final String? productCode;
  final num unitPrice;
  final int quantity;
  final num lineTotal;

  @override
  List<Object?> get props => [id, productId, productName, productCode, unitPrice, quantity, lineTotal];
}

/// One step of an order's timeline.
final class OrderStatusChange extends Equatable {
  const OrderStatusChange({
    required this.status,
    required this.changedAt,
    required this.actor,
    this.changedByName,
    this.note,
  });

  final OrderStatus status;
  final DateTime changedAt;
  final OrderActor actor;
  final String? changedByName;
  final String? note;

  @override
  List<Object?> get props => [status, changedAt, actor, changedByName, note];
}

/// An order with its lines and its timeline (oldest step first).
final class Order extends Equatable {
  const Order({
    required this.id,
    required this.number,
    required this.clientId,
    required this.status,
    required this.total,
    required this.placedAt,
    required this.lines,
    required this.history,
    this.clientName,
    this.notes,
    this.updatedAt,
  });

  final String id;
  final int number;
  final String clientId;
  final String? clientName;
  final OrderStatus status;
  final String? notes;
  final num total;
  final DateTime placedAt;
  final DateTime? updatedAt;
  final List<OrderLine> lines;
  final List<OrderStatusChange> history;

  @override
  List<Object?> get props => [
    id,
    number,
    clientId,
    clientName,
    status,
    notes,
    total,
    placedAt,
    updatedAt,
    lines,
    history,
  ];
}
