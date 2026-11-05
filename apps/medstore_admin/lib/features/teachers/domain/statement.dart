import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../wallets/domain/wallet.dart';

/// A teacher's account for a period: what was invoiced and paid in, what is open, and today's position.
final class Statement extends Equatable {
  const Statement({
    required this.clientId,
    required this.clientName,
    required this.paymentTerms,
    required this.from,
    required this.to,
    required this.generatedOn,
    required this.invoices,
    required this.movements,
    required this.openDebts,
    required this.totals,
    this.phone,
    this.schoolName,
  });

  final String clientId;
  final String clientName;
  final String? phone;
  final String? schoolName;
  final PaymentTerms paymentTerms;
  final DateTime from;
  final DateTime to;
  final DateTime generatedOn;
  final List<StatementInvoice> invoices;
  final List<StatementMovement> movements;
  final List<StatementDebt> openDebts;
  final StatementTotals totals;

  @override
  List<Object?> get props => [clientId, from, to, generatedOn, invoices, movements, openDebts, totals];
}

final class StatementInvoice extends Equatable {
  const StatementInvoice({
    required this.id,
    required this.label,
    required this.issueDate,
    required this.dueDate,
    required this.total,
    required this.amountPaid,
    required this.amountDue,
    required this.isVoided,
    required this.isOverdue,
  });

  final String id;
  final String label;
  final DateTime issueDate;
  final DateTime dueDate;
  final num total;
  final num amountPaid;
  final num amountDue;
  final bool isVoided;
  final bool isOverdue;

  @override
  List<Object?> get props => [
    id,
    label,
    issueDate,
    dueDate,
    total,
    amountPaid,
    amountDue,
    isVoided,
    isOverdue,
  ];
}

final class StatementMovement extends Equatable {
  const StatementMovement({
    required this.occurredAt,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.isVoided,
    this.receiptLabel,
    this.note,
  });

  final DateTime occurredAt;
  final WalletTransactionType type;
  final num amount;
  final num balanceAfter;
  final String? receiptLabel;
  final String? note;
  final bool isVoided;

  @override
  List<Object?> get props => [occurredAt, type, amount, balanceAfter, receiptLabel, note, isVoided];
}

final class StatementDebt extends Equatable {
  const StatementDebt({
    required this.id,
    required this.description,
    required this.dueDate,
    required this.amount,
    required this.amountDue,
    required this.isOverdue,
  });

  final String id;
  final String description;
  final DateTime dueDate;
  final num amount;
  final num amountDue;
  final bool isOverdue;

  @override
  List<Object?> get props => [id, description, dueDate, amount, amountDue, isOverdue];
}

final class StatementTotals extends Equatable {
  const StatementTotals({
    required this.invoiced,
    required this.deposited,
    required this.paidFromWallet,
    required this.owedNow,
    required this.overdueNow,
    required this.walletBalanceNow,
  });

  final num invoiced;
  final num deposited;
  final num paidFromWallet;
  final num owedNow;
  final num overdueNow;
  final num walletBalanceNow;

  @override
  List<Object?> get props => [invoiced, deposited, paidFromWallet, owedNow, overdueNow, walletBalanceNow];
}
