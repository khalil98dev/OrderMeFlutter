import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/forms/form_values.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  const InvoiceRepositoryImpl(this._api);

  static const _admin = '/api/admin/invoices';
  static const _shared = '/api/invoices';

  final ApiClient _api;

  @override
  Future<Result<PagedList<InvoiceSummary>>> list(InvoiceFilter filter, {int page = 1}) => _api.get(
    _admin,
    query: {
      if (filter.clientId != null) 'clientId': filter.clientId,
      if (filter.paymentStatus != null) 'paymentStatus': filter.paymentStatus!.apiName,
      if (filter.onlyOverdue) 'onlyOverdue': true,
      if (filter.includeVoided) 'includeVoided': true,
      if (filter.from != null) 'from': apiDay(filter.from!),
      if (filter.to != null) 'to': apiDay(filter.to!),
      'page': page,
      'pageSize': 50,
    },
    decode: (json) => PagedList.fromJson(json, summaryFromJson),
  );

  @override
  Future<Result<Invoice>> get(String id) => _api.get('$_shared/$id', decode: invoiceFromJson);

  @override
  Future<Result<List<UninvoicedProduct>>> uninvoiced(String clientId) => _api.get(
    '$_admin/uninvoiced',
    query: {'clientId': clientId},
    decode: (json) => [for (final row in json! as List<Object?>) _uninvoiced(row)],
  );

  @override
  Future<Result<Invoice>> issue(InvoiceDraft draft) => _api.post(
    _admin,
    data: {
      'clientId': draft.clientId,
      'notes': optionalText(draft.notes),
      'lines': [
        for (final row in draft.selected)
          {'productId': row.productId, 'unitPrice': row.unitPrice, 'quantity': draft.quantityOf(row)},
      ],
    },
    decode: invoiceFromJson,
  );

  @override
  Future<Result<void>> voidInvoice(String id, String reason) =>
      _api.post('$_admin/$id/void', data: {'reason': reason}, decode: ApiClient.ignoreBody);

  @override
  Future<Result<Invoice>> settle(String id, {num? amount}) =>
      _api.post('$_admin/$id/settle', data: {'amount': amount}, decode: invoiceFromJson);

  @override
  Future<Result<Uint8List>> pdf(String id) => _api.get(
    '$_shared/$id/pdf',
    options: Options(responseType: ResponseType.bytes),
    decode: (bytes) => Uint8List.fromList(bytes! as List<int>),
  );

  static InvoiceSummary summaryFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return InvoiceSummary(
      id: json.string('id'),
      number: json.integer('number'),
      label: json.string('label'),
      clientId: json.string('clientId'),
      clientName: json.stringOrNull('clientName'),
      issueDate: json.day('issueDate'),
      dueDate: json.day('dueDate'),
      total: json.money('total'),
      amountPaid: json.moneyOrNull('amountPaid'),
      amountDue: json.moneyOrNull('amountDue'),
      paymentStatus: InvoicePaymentStatus.fromApiOrNull(json.stringOrNull('paymentStatus')),
      isVoided: json.boolean('isVoided'),
      isOverdue: json.booleanOrNull('isOverdue'),
    );
  }

  static Invoice invoiceFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return Invoice(
      summary: summaryFromJson(raw),
      paymentTerms: PaymentTerms.fromApi(json.stringOrNull('paymentTerms')),
      notes: json.stringOrNull('notes'),
      voidedAt: json.instantOrNull('voidedAt'),
      voidReason: json.stringOrNull('voidReason'),
      lines: json.list('lines', (raw) {
        final line = JsonMap.of(raw);
        return InvoiceLine(
          id: line.string('id'),
          productId: line.string('productId'),
          productName: line.string('productName'),
          productCode: line.stringOrNull('productCode'),
          unitPrice: line.money('unitPrice'),
          quantity: line.integer('quantity'),
          lineTotal: line.money('lineTotal'),
          orders: line.list('orders', (raw) {
            final order = JsonMap.of(raw);
            return InvoiceLineOrder(
              orderId: order.string('orderId'),
              orderNumber: order.integer('orderNumber'),
              quantity: order.integer('quantity'),
            );
          }),
        );
      }),
      payments: json.list('payments', (raw) {
        final payment = JsonMap.of(raw);
        return InvoicePayment(
          amount: payment.money('amount'),
          paidAt: payment.instant('paidAt'),
          refundedAt: payment.instantOrNull('refundedAt'),
        );
      }),
    );
  }

  static UninvoicedProduct _uninvoiced(Object? raw) {
    final json = JsonMap.of(raw);
    return UninvoicedProduct(
      productId: json.string('productId'),
      productName: json.string('productName'),
      productCode: json.stringOrNull('productCode'),
      unitPrice: json.money('unitPrice'),
      quantity: json.integer('quantity'),
      amount: json.money('amount'),
      orders: json.list('orders', (raw) {
        final line = JsonMap.of(raw);
        return UninvoicedOrderLine(
          orderId: line.string('orderId'),
          orderNumber: line.integer('orderNumber'),
          orderStatus: OrderStatus.fromApi(line.stringOrNull('orderStatus')),
          placedAt: line.instant('placedAt'),
          quantity: line.integer('quantity'),
        );
      }),
    );
  }
}
