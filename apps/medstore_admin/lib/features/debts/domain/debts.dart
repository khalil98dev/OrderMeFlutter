import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../invoices/domain/invoice_repository.dart' show SettleParams;

/// What one teacher owes: unpaid invoices (overdue past their due date) plus debts entered by hand.
final class DebtOverview extends Equatable {
  const DebtOverview({
    required this.clientId,
    required this.clientName,
    required this.overdueInvoices,
    required this.upcomingInvoices,
    required this.openDebts,
    required this.overdue,
    required this.totalOwed,
    required this.walletBalance,
    this.phone,
    this.oldestDueDate,
  });

  final String clientId;
  final String clientName;
  final String? phone;
  final num overdueInvoices;
  final num upcomingInvoices;
  final num openDebts;
  final num overdue;
  final num totalOwed;
  final num walletBalance;
  final DateTime? oldestDueDate;

  @override
  List<Object?> get props => [clientId, overdue, totalOwed, walletBalance, oldestDueDate];
}

enum DebtItemKind {
  invoice('Invoice'),
  debt('Debt');

  const DebtItemKind(this.apiName);

  final String apiName;

  static DebtItemKind fromApi(String? value) =>
      values.firstWhere((kind) => kind.apiName == value, orElse: () => debt);
}

/// One thing a teacher owes: an unpaid invoice or an open debt.
final class DebtItem extends Equatable {
  const DebtItem({
    required this.kind,
    required this.id,
    required this.label,
    required this.date,
    required this.dueDate,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.isOverdue,
  });

  final DebtItemKind kind;
  final String id;
  final String label;
  final DateTime date;
  final DateTime dueDate;
  final num amount;
  final num amountPaid;
  final num amountDue;
  final bool isOverdue;

  @override
  List<Object?> get props => [kind, id, amountDue, isOverdue];
}

/// Everything one teacher owes, item by item, oldest due first.
final class ClientDebts extends Equatable {
  const ClientDebts({required this.totals, required this.items});

  final DebtOverview totals;
  final List<DebtItem> items;

  @override
  List<Object?> get props => [totals, items];
}

/// A debt the team entered by hand (owed from before the app, an adjustment).
final class Debt extends Equatable {
  const Debt({
    required this.id,
    required this.clientId,
    required this.description,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.amountWrittenOff,
    required this.dueDate,
    required this.createdAt,
    required this.isOverdue,
    this.clientName,
    this.writtenOffAt,
    this.writeOffReason,
  });

  final String id;
  final String clientId;
  final String? clientName;
  final String description;
  final num amount;
  final num amountPaid;
  final num amountDue;
  final num amountWrittenOff;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? writtenOffAt;
  final String? writeOffReason;
  final bool isOverdue;

  bool get isOpen => amountDue > 0;

  @override
  List<Object?> get props => [
    id,
    amount,
    amountPaid,
    amountDue,
    amountWrittenOff,
    dueDate,
    writtenOffAt,
    isOverdue,
  ];
}

final class DebtFilter extends Equatable {
  const DebtFilter({this.search = '', this.onlyOwing = true});

  final String search;

  /// Hides teachers who owe nothing (the API's default).
  final bool onlyOwing;

  @override
  List<Object?> get props => [search, onlyOwing];
}

enum DebtDraftField { teacher, description, amount }

final class DebtDraft extends Equatable {
  const DebtDraft({required this.clientId, required this.description, required this.amount, this.dueDate});

  final String? clientId;
  final String description;

  /// Null when the typed amount is not valid.
  final num? amount;

  /// Null: due today.
  final DateTime? dueDate;

  static const maxDescription = 500;

  Set<DebtDraftField> validate() => {
    if (clientId == null) DebtDraftField.teacher,
    if (description.trim().isEmpty || description.trim().length > maxDescription) DebtDraftField.description,
    if (amount == null) DebtDraftField.amount,
  };

  @override
  List<Object?> get props => [clientId, description, amount, dueDate];
}

/// `/api/admin/debts`. Teachers never see this.
abstract interface class DebtRepository {
  /// Every teacher with what they owe, most overdue first.
  Future<Result<PagedList<DebtOverview>>> overview(DebtFilter filter, {int page = 1});

  Future<Result<ClientDebts>> forClient(String clientId, {bool includeClosed = false});

  Future<Result<Debt>> get(String id);

  Future<Result<Debt>> create(DebtDraft draft);

  /// Pays from the wallet: [amount], or as much as possible.
  Future<Result<Debt>> settle(String id, {num? amount});

  /// Forgives what is left.
  Future<Result<Debt>> writeOff(String id, String reason);
}

class ListDebtOverview {
  const ListDebtOverview(this._repository);

  final DebtRepository _repository;

  Future<Result<PagedList<DebtOverview>>> call(DebtFilter filter, {int page = 1}) =>
      _repository.overview(filter, page: page);
}

final class ClientDebtsParams {
  const ClientDebtsParams(this.clientId, {this.includeClosed = false});

  final String clientId;
  final bool includeClosed;
}

class GetClientDebts implements UseCase<ClientDebts, ClientDebtsParams> {
  const GetClientDebts(this._repository);

  final DebtRepository _repository;

  @override
  Future<Result<ClientDebts>> call(ClientDebtsParams params) =>
      _repository.forClient(params.clientId, includeClosed: params.includeClosed);
}

class GetDebt implements UseCase<Debt, String> {
  const GetDebt(this._repository);

  final DebtRepository _repository;

  @override
  Future<Result<Debt>> call(String id) => _repository.get(id);
}

class CreateDebt implements UseCase<Debt, DebtDraft> {
  const CreateDebt(this._repository);

  final DebtRepository _repository;

  @override
  Future<Result<Debt>> call(DebtDraft draft) => _repository.create(draft);
}

class SettleDebt implements UseCase<Debt, SettleParams> {
  const SettleDebt(this._repository);

  final DebtRepository _repository;

  @override
  Future<Result<Debt>> call(SettleParams params) => _repository.settle(params.id, amount: params.amount);
}

final class WriteOffParams {
  const WriteOffParams(this.debtId, this.reason);

  final String debtId;
  final String reason;
}

class WriteOffDebt implements UseCase<Debt, WriteOffParams> {
  const WriteOffDebt(this._repository);

  final DebtRepository _repository;

  @override
  Future<Result<Debt>> call(WriteOffParams params) => _repository.writeOff(params.debtId, params.reason);
}
