import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

enum InvoicePaymentStatus {
  unpaid('Unpaid'),
  partiallyPaid('PartiallyPaid'),
  paid('Paid');

  const InvoicePaymentStatus(this.apiName);

  final String apiName;

  static InvoicePaymentStatus? fromApiOrNull(String? value) => switch (value) {
    null => null,
    _ => values.firstWhere((status) => status.apiName == value, orElse: () => unpaid),
  };
}

/// A row in an invoice list. The payment fields are secured: null for a role that may not read them.
final class InvoiceSummary extends Equatable {
  const InvoiceSummary({
    required this.id,
    required this.number,
    required this.label,
    required this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.total,
    required this.isVoided,
    this.clientName,
    this.amountPaid,
    this.amountDue,
    this.paymentStatus,
    this.isOverdue,
  });

  final String id;
  final int number;

  /// "INV-000042".
  final String label;
  final String clientId;
  final String? clientName;
  final DateTime issueDate;
  final DateTime dueDate;
  final num total;
  final num? amountPaid;
  final num? amountDue;
  final InvoicePaymentStatus? paymentStatus;
  final bool isVoided;
  final bool? isOverdue;

  @override
  List<Object?> get props => [
    id,
    label,
    clientId,
    total,
    amountPaid,
    amountDue,
    paymentStatus,
    isVoided,
    isOverdue,
  ];
}

/// Which orders an invoice line's copies came from.
final class InvoiceLineOrder extends Equatable {
  const InvoiceLineOrder({required this.orderId, required this.orderNumber, required this.quantity});

  final String orderId;
  final int orderNumber;
  final int quantity;

  @override
  List<Object?> get props => [orderId, orderNumber, quantity];
}

final class InvoiceLine extends Equatable {
  const InvoiceLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.orders,
    this.productCode,
  });

  final String id;
  final String productId;
  final String productName;
  final String? productCode;
  final num unitPrice;
  final int quantity;
  final num lineTotal;
  final List<InvoiceLineOrder> orders;

  @override
  List<Object?> get props => [id, productId, unitPrice, quantity, lineTotal, orders];
}

/// Wallet money applied to an invoice (refunded when the invoice is voided).
final class InvoicePayment extends Equatable {
  const InvoicePayment({required this.amount, required this.paidAt, this.refundedAt});

  final num amount;
  final DateTime paidAt;
  final DateTime? refundedAt;

  @override
  List<Object?> get props => [amount, paidAt, refundedAt];
}

/// An invoice with its lines and payments. Never edited: voided instead.
final class Invoice extends Equatable {
  const Invoice({
    required this.summary,
    required this.paymentTerms,
    required this.lines,
    required this.payments,
    this.notes,
    this.voidedAt,
    this.voidReason,
  });

  final InvoiceSummary summary;
  final PaymentTerms paymentTerms;
  final String? notes;
  final DateTime? voidedAt;
  final String? voidReason;
  final List<InvoiceLine> lines;
  final List<InvoicePayment> payments;

  String get id => summary.id;

  bool get canSettle => !summary.isVoided && (summary.amountDue ?? 0) > 0;

  @override
  List<Object?> get props => [summary, paymentTerms, notes, voidedAt, voidReason, lines, payments];
}

/// What the invoices list shows (issue date, both ends included).
final class InvoiceFilter extends Equatable {
  const InvoiceFilter({
    this.clientId,
    this.clientName,
    this.paymentStatus,
    this.onlyOverdue = false,
    this.includeVoided = false,
    this.from,
    this.to,
  });

  final String? clientId;

  /// Shown in the teacher filter; not sent.
  final String? clientName;
  final InvoicePaymentStatus? paymentStatus;
  final bool onlyOverdue;
  final bool includeVoided;
  final DateTime? from;
  final DateTime? to;

  InvoiceFilter copyWith({
    (String, String)? Function()? client,
    InvoicePaymentStatus? Function()? paymentStatus,
    bool? onlyOverdue,
    bool? includeVoided,
    DateTime? Function()? from,
    DateTime? Function()? to,
  }) {
    final teacher = client == null ? null : client();
    return InvoiceFilter(
      clientId: client == null ? clientId : teacher?.$1,
      clientName: client == null ? clientName : teacher?.$2,
      paymentStatus: paymentStatus == null ? this.paymentStatus : paymentStatus(),
      onlyOverdue: onlyOverdue ?? this.onlyOverdue,
      includeVoided: includeVoided ?? this.includeVoided,
      from: from == null ? this.from : from(),
      to: to == null ? this.to : to(),
    );
  }

  @override
  List<Object?> get props => [clientId, paymentStatus, onlyOverdue, includeVoided, from, to];
}

/// One order line whose copies are not yet invoiced.
final class UninvoicedOrderLine extends Equatable {
  const UninvoicedOrderLine({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.placedAt,
    required this.quantity,
  });

  final String orderId;
  final int orderNumber;
  final OrderStatus orderStatus;
  final DateTime placedAt;
  final int quantity;

  @override
  List<Object?> get props => [orderId, orderNumber, orderStatus, placedAt, quantity];
}

/// Copies of one product at one price, printed but not yet invoiced, and the orders they are on.
final class UninvoicedProduct extends Equatable {
  const UninvoicedProduct({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.amount,
    required this.orders,
    this.productCode,
  });

  final String productId;
  final String productName;
  final String? productCode;
  final num unitPrice;
  final int quantity;
  final num amount;
  final List<UninvoicedOrderLine> orders;

  /// A product can be uninvoiced at two prices (a price change between orders): one row each.
  String get key => '$productId@$unitPrice';

  @override
  List<Object?> get props => [productId, unitPrice, quantity, amount, orders];
}

enum InvoiceDraftProblem { teacherRequired, nothingSelected, quantityTooHigh }

/// The invoice being prepared: how many copies of each uninvoiced row to bill.
final class InvoiceDraft extends Equatable {
  const InvoiceDraft({
    required this.clientId,
    required this.available,
    this.quantities = const {},
    this.notes = '',
  });

  final String? clientId;
  final List<UninvoicedProduct> available;

  /// [UninvoicedProduct.key] → copies to invoice.
  final Map<String, int> quantities;
  final String notes;

  /// Every copy of every row: the usual case.
  InvoiceDraft selectAll() => _copy(quantities: {for (final row in available) row.key: row.quantity});

  InvoiceDraft setQuantity(String key, int quantity) => _copy(quantities: {...quantities, key: quantity});

  InvoiceDraft withNotes(String value) => _copy(notes: value);

  InvoiceDraft _copy({Map<String, int>? quantities, String? notes}) => InvoiceDraft(
    clientId: clientId,
    available: available,
    quantities: quantities ?? this.quantities,
    notes: notes ?? this.notes,
  );

  int quantityOf(UninvoicedProduct row) => quantities[row.key] ?? 0;

  num get total => available.fold<num>(0, (sum, row) => sum + row.unitPrice * quantityOf(row));

  List<UninvoicedProduct> get selected => [
    for (final row in available)
      if (quantityOf(row) > 0) row,
  ];

  Set<InvoiceDraftProblem> validate() => {
    if (clientId == null) InvoiceDraftProblem.teacherRequired,
    if (selected.isEmpty) InvoiceDraftProblem.nothingSelected,
    if (available.any((row) => quantityOf(row) > row.quantity)) InvoiceDraftProblem.quantityTooHigh,
  };

  @override
  List<Object?> get props => [clientId, available, quantities, notes];
}
