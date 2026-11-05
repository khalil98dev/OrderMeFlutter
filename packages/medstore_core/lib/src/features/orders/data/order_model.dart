import '../../../core/json/json_map.dart';
import '../domain/entities/order.dart';

/// Reads the API's `OrderSummaryDto` and `OrderDto`.
abstract final class OrderModel {
  static OrderSummary summaryFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return OrderSummary(
      id: json.string('id'),
      number: json.integer('number'),
      clientId: json.string('clientId'),
      clientName: json.stringOrNull('clientName'),
      status: OrderStatus.fromApi(json.stringOrNull('status')),
      total: json.money('total'),
      lineCount: json.integer('lineCount'),
      totalQuantity: json.integer('totalQuantity'),
      placedAt: json.instant('placedAt'),
      updatedAt: json.instantOrNull('updatedAt'),
    );
  }

  static Order fromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return Order(
      id: json.string('id'),
      number: json.integer('number'),
      clientId: json.string('clientId'),
      clientName: json.stringOrNull('clientName'),
      status: OrderStatus.fromApi(json.stringOrNull('status')),
      notes: json.stringOrNull('notes'),
      total: json.money('total'),
      placedAt: json.instant('placedAt'),
      updatedAt: json.instantOrNull('updatedAt'),
      lines: json.list('lines', _line),
      history: json.list('history', _change),
    );
  }

  static OrderLine _line(Object? raw) {
    final json = JsonMap.of(raw);
    return OrderLine(
      id: json.string('id'),
      productId: json.string('productId'),
      productName: json.string('productName'),
      productCode: json.stringOrNull('productCode'),
      unitPrice: json.money('unitPrice'),
      quantity: json.integer('quantity'),
      lineTotal: json.money('lineTotal'),
    );
  }

  static OrderStatusChange _change(Object? raw) {
    final json = JsonMap.of(raw);
    return OrderStatusChange(
      status: OrderStatus.fromApi(json.stringOrNull('status')),
      changedAt: json.instant('changedAt'),
      actor: OrderActor.fromApi(json.stringOrNull('actor')),
      changedByName: json.stringOrNull('changedByName'),
      note: json.stringOrNull('note'),
    );
  }
}
