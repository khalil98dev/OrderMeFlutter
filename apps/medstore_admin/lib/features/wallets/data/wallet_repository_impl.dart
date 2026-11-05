import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/wallet.dart';
import '../domain/wallet_repository.dart';
import 'wallet_models.dart';

/// Money is never cached: every screen shows the ledger as it is now.
class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._api);

  static const _path = '/api/admin/wallets';

  final ApiClient _api;

  @override
  Future<Result<PagedList<Wallet>>> list(WalletFilter filter, {int page = 1}) => _api.get(
    _path,
    query: {if (filter.search.isNotEmpty) 'search': filter.search, 'page': page, 'pageSize': 50},
    decode: (json) => PagedList.fromJson(json, WalletModels.walletFromJson),
  );

  @override
  Future<Result<Wallet>> get(String clientId) =>
      _api.get('$_path/$clientId', decode: WalletModels.walletFromJson);

  @override
  Future<Result<PagedList<WalletTransaction>>> transactions(TransactionFilter filter, {int page = 1}) =>
      _api.get(
        '$_path/${filter.clientId}/transactions',
        query: {
          if (filter.type != null) 'type': filter.type!.apiName,
          if (filter.from != null) 'from': apiDay(filter.from!),
          // The API's "to" is exclusive; the screen's is the last day shown.
          if (filter.to != null) 'to': apiDay(filter.to!.add(const Duration(days: 1))),
          'page': page,
          'pageSize': 50,
        },
        decode: (json) => PagedList.fromJson(json, WalletModels.transactionFromJson),
      );

  @override
  Future<Result<WalletTransaction>> deposit(String clientId, DepositDraft draft) => _api.post(
    '$_path/$clientId/deposits',
    data: {
      'amount': draft.amount,
      'method': draft.method.apiName,
      'reference': draft.reference,
      'note': draft.note,
    },
    decode: WalletModels.transactionFromJson,
  );

  @override
  Future<Result<WalletTransaction>> withdraw(String clientId, WithdrawalDraft draft) => _api.post(
    '$_path/$clientId/withdrawals',
    data: {'amount': draft.amount, 'note': draft.note},
    decode: WalletModels.transactionFromJson,
  );

  @override
  Future<Result<SettlementResult>> settle(String clientId) =>
      _api.post('$_path/$clientId/settle', decode: WalletModels.settlementFromJson);

  @override
  Future<Result<WalletTransaction>> voidTransaction(String transactionId, String reason) => _api.post(
    '$_path/transactions/$transactionId/void',
    data: {'reason': reason},
    decode: WalletModels.transactionFromJson,
  );

  @override
  Future<Result<Uint8List>> receipt(String transactionId) => _api.get(
    '/api/wallet/transactions/$transactionId/receipt',
    options: Options(responseType: ResponseType.bytes),
    decode: (bytes) => Uint8List.fromList(bytes! as List<int>),
  );
}
