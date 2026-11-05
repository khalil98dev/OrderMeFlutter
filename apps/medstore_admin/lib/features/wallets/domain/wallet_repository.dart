import 'dart:typed_data';

import 'package:medstore_core/medstore_core.dart';

import 'wallet.dart';

/// `/api/admin/wallets` (balances, ledger, deposits, withdrawals, settlement, voids) and the receipt
/// PDF at `/api/wallet/transactions/{id}/receipt`, which the team shares with the teacher app.
abstract interface class WalletRepository {
  /// Every teacher with their balance, biggest first.
  Future<Result<PagedList<Wallet>>> list(WalletFilter filter, {int page = 1});

  Future<Result<Wallet>> get(String clientId);

  /// Newest first.
  Future<Result<PagedList<WalletTransaction>>> transactions(TransactionFilter filter, {int page = 1});

  /// Answers the entry with its receipt number (REC-000042).
  Future<Result<WalletTransaction>> deposit(String clientId, DepositDraft draft);

  Future<Result<WalletTransaction>> withdraw(String clientId, WithdrawalDraft draft);

  /// Pays the teacher's oldest amounts due from the wallet.
  Future<Result<SettlementResult>> settle(String clientId);

  /// Cancels a deposit or withdrawal; answers the reversing entry.
  Future<Result<WalletTransaction>> voidTransaction(String transactionId, String reason);

  Future<Result<Uint8List>> receipt(String transactionId);
}

class ListWallets {
  const ListWallets(this._repository);

  final WalletRepository _repository;

  Future<Result<PagedList<Wallet>>> call(WalletFilter filter, {int page = 1}) =>
      _repository.list(filter, page: page);
}

class GetWallet implements UseCase<Wallet, String> {
  const GetWallet(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<Wallet>> call(String clientId) => _repository.get(clientId);
}

class ListTransactions {
  const ListTransactions(this._repository);

  final WalletRepository _repository;

  Future<Result<PagedList<WalletTransaction>>> call(TransactionFilter filter, {int page = 1}) =>
      _repository.transactions(filter, page: page);
}

final class DepositParams {
  const DepositParams(this.clientId, this.draft);

  final String clientId;
  final DepositDraft draft;
}

class RecordDeposit implements UseCase<WalletTransaction, DepositParams> {
  const RecordDeposit(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<WalletTransaction>> call(DepositParams params) =>
      _repository.deposit(params.clientId, params.draft);
}

final class WithdrawalParams {
  const WithdrawalParams(this.clientId, this.draft);

  final String clientId;
  final WithdrawalDraft draft;
}

class RecordWithdrawal implements UseCase<WalletTransaction, WithdrawalParams> {
  const RecordWithdrawal(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<WalletTransaction>> call(WithdrawalParams params) =>
      _repository.withdraw(params.clientId, params.draft);
}

class SettleWallet implements UseCase<SettlementResult, String> {
  const SettleWallet(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<SettlementResult>> call(String clientId) => _repository.settle(clientId);
}

final class VoidTransactionParams {
  const VoidTransactionParams(this.transactionId, this.reason);

  final String transactionId;
  final String reason;
}

class VoidTransaction implements UseCase<WalletTransaction, VoidTransactionParams> {
  const VoidTransaction(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<WalletTransaction>> call(VoidTransactionParams params) =>
      _repository.voidTransaction(params.transactionId, params.reason);
}

class DownloadReceipt implements UseCase<Uint8List, String> {
  const DownloadReceipt(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<Uint8List>> call(String transactionId) => _repository.receipt(transactionId);
}
