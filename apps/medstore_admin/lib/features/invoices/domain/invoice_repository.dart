import 'dart:typed_data';

import 'package:medstore_core/medstore_core.dart';

import 'invoice.dart';

/// `/api/admin/invoices` for the team's actions; one invoice and its PDF are read through
/// `/api/invoices/{id}` (the team sees every teacher's, with the payment fields).
abstract interface class InvoiceRepository {
  /// Newest first.
  Future<Result<PagedList<InvoiceSummary>>> list(InvoiceFilter filter, {int page = 1});

  Future<Result<Invoice>> get(String id);

  /// What can be invoiced for a teacher.
  Future<Result<List<UninvoicedProduct>>> uninvoiced(String clientId);

  /// Copies are taken from the oldest orders first; with AutoSettle on, the wallet pays at once.
  Future<Result<Invoice>> issue(InvoiceDraft draft);

  /// Copies go back to their orders and payments back to the wallet.
  Future<Result<void>> voidInvoice(String id, String reason);

  /// Pays from the wallet: [amount], or as much as possible when null.
  Future<Result<Invoice>> settle(String id, {num? amount});

  /// Stamped void when voided.
  Future<Result<Uint8List>> pdf(String id);
}

class ListInvoices {
  const ListInvoices(this._repository);

  final InvoiceRepository _repository;

  Future<Result<PagedList<InvoiceSummary>>> call(InvoiceFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

class GetInvoice implements UseCase<Invoice, String> {
  const GetInvoice(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<Invoice>> call(String id) => _repository.get(id);
}

class ListUninvoiced implements UseCase<List<UninvoicedProduct>, String> {
  const ListUninvoiced(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<List<UninvoicedProduct>>> call(String clientId) => _repository.uninvoiced(clientId);
}

class IssueInvoice implements UseCase<Invoice, InvoiceDraft> {
  const IssueInvoice(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<Invoice>> call(InvoiceDraft draft) => _repository.issue(draft);
}

final class VoidInvoiceParams {
  const VoidInvoiceParams(this.invoiceId, this.reason);

  final String invoiceId;
  final String reason;
}

class VoidInvoice implements UseCase<void, VoidInvoiceParams> {
  const VoidInvoice(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<void>> call(VoidInvoiceParams params) =>
      _repository.voidInvoice(params.invoiceId, params.reason);
}

final class SettleParams {
  const SettleParams(this.id, {this.amount});

  final String id;

  /// Null: as much as the wallet and the amount due allow.
  final num? amount;
}

class SettleInvoice implements UseCase<Invoice, SettleParams> {
  const SettleInvoice(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<Invoice>> call(SettleParams params) => _repository.settle(params.id, amount: params.amount);
}

class DownloadInvoicePdf implements UseCase<Uint8List, String> {
  const DownloadInvoicePdf(this._repository);

  final InvoiceRepository _repository;

  @override
  Future<Result<Uint8List>> call(String id) => _repository.pdf(id);
}
