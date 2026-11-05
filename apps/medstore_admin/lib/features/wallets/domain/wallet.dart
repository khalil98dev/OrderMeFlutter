import 'package:equatable/equatable.dart';

/// What a ledger entry is. Positive amounts come in, negative go out.
enum WalletTransactionType {
  deposit('Deposit'),
  withdrawal('Withdrawal'),
  reversal('Reversal'),
  invoicePayment('InvoicePayment'),
  otherPayment('OtherPayment');

  const WalletTransactionType(this.apiName);

  final String apiName;

  static WalletTransactionType fromApi(String? value) =>
      values.firstWhere((type) => type.apiName == value, orElse: () => otherPayment);

  /// Only money recorded by hand can be voided; payments are undone by voiding the invoice or debt.
  bool get canBeVoided => this == deposit || this == withdrawal;
}

enum PaymentMethod {
  cash('Cash'),
  bankTransfer('BankTransfer'),
  other('Other');

  const PaymentMethod(this.apiName);

  final String apiName;

  static PaymentMethod? fromApiOrNull(String? value) => switch (value) {
    null => null,
    _ => values.firstWhere((method) => method.apiName == value, orElse: () => other),
  };
}

/// A teacher's wallet. A teacher who never deposited has a zero balance and no entries.
final class Wallet extends Equatable {
  const Wallet({
    required this.clientId,
    required this.balance,
    required this.totalDeposited,
    this.clientName,
    this.lastMovementAt,
  });

  final String clientId;
  final String? clientName;
  final num balance;
  final num totalDeposited;
  final DateTime? lastMovementAt;

  @override
  List<Object?> get props => [clientId, clientName, balance, totalDeposited, lastMovementAt];
}

/// One ledger entry. Never edited: a mistake is voided, which adds a reversal.
final class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.occurredAt,
    required this.isVoided,
    required this.hasReceipt,
    this.method,
    this.reference,
    this.note,
    this.receiptNumber,
    this.receiptLabel,
    this.recordedByName,
    this.voidedAt,
    this.voidReason,
    this.reversalOfId,
  });

  final String id;
  final WalletTransactionType type;
  final num amount;
  final num balanceAfter;
  final DateTime occurredAt;
  final PaymentMethod? method;
  final String? reference;
  final String? note;
  final int? receiptNumber;

  /// "REC-000042".
  final String? receiptLabel;
  final String? recordedByName;
  final bool isVoided;
  final DateTime? voidedAt;
  final String? voidReason;
  final String? reversalOfId;
  final bool hasReceipt;

  bool get canBeVoided => type.canBeVoided && !isVoided;

  @override
  List<Object?> get props => [id, type, amount, balanceAfter, occurredAt, isVoided, voidedAt, hasReceipt];
}

/// The wallets list: search by teacher name.
final class WalletFilter extends Equatable {
  const WalletFilter({this.search = ''});

  final String search;

  @override
  List<Object?> get props => [search];
}

/// One wallet's entries: by type and period (from inclusive, to exclusive on the API).
final class TransactionFilter extends Equatable {
  const TransactionFilter({required this.clientId, this.type, this.from, this.to});

  final String clientId;
  final WalletTransactionType? type;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [clientId, type, from, to];
}

/// What a settlement paid, and what is left in the wallet.
final class SettlementResult extends Equatable {
  const SettlementResult({required this.paid, required this.wallet});

  final num paid;
  final Wallet wallet;

  @override
  List<Object?> get props => [paid, wallet];
}

/// Money the teacher paid in.
final class DepositDraft extends Equatable {
  const DepositDraft({required this.amount, this.method = PaymentMethod.cash, this.reference, this.note});

  /// Null when the typed amount is not valid.
  final num? amount;
  final PaymentMethod method;
  final String? reference;
  final String? note;

  @override
  List<Object?> get props => [amount, method, reference, note];
}

/// Money handed back to the teacher (never more than the balance; the server checks).
final class WithdrawalDraft extends Equatable {
  const WithdrawalDraft({required this.amount, this.note});

  final num? amount;
  final String? note;

  @override
  List<Object?> get props => [amount, note];
}
