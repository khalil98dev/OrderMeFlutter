import 'package:medstore_core/medstore_core.dart';

import '../domain/wallet.dart';

/// Reads the API's `WalletDto`, `WalletTransactionDto` and `SettlementResultDto`.
abstract final class WalletModels {
  static WalletTransactionType typeFromApi(String? value) => WalletTransactionType.fromApi(value);

  static Wallet walletFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return Wallet(
      clientId: json.string('clientId'),
      clientName: json.stringOrNull('clientName'),
      balance: json.money('balance'),
      totalDeposited: json.money('totalDeposited'),
      lastMovementAt: json.instantOrNull('lastMovementAt'),
    );
  }

  static WalletTransaction transactionFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return WalletTransaction(
      id: json.string('id'),
      type: WalletTransactionType.fromApi(json.stringOrNull('type')),
      amount: json.money('amount'),
      balanceAfter: json.money('balanceAfter'),
      occurredAt: json.instant('occurredAt'),
      method: PaymentMethod.fromApiOrNull(json.stringOrNull('method')),
      reference: json.stringOrNull('reference'),
      note: json.stringOrNull('note'),
      receiptNumber: json.integerOrNull('receiptNumber'),
      receiptLabel: json.stringOrNull('receiptLabel'),
      recordedByName: json.stringOrNull('recordedByName'),
      isVoided: json.boolean('isVoided'),
      voidedAt: json.instantOrNull('voidedAt'),
      voidReason: json.stringOrNull('voidReason'),
      reversalOfId: json.stringOrNull('reversalOfId'),
      hasReceipt: json.booleanOrNull('hasReceipt') ?? false,
    );
  }

  static SettlementResult settlementFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return SettlementResult(paid: json.money('paid'), wallet: walletFromJson(json['wallet']));
  }
}
