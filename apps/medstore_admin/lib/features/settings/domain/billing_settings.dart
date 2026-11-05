import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// How billing works for everyone.
final class BillingSettings extends Equatable {
  const BillingSettings({
    required this.autoSettle,
    required this.defaultPaymentTerms,
    this.updatedAt,
    this.updatedByName,
  });

  /// Wallet money pays what is due right after each invoice, debt and deposit.
  final bool autoSettle;

  /// The terms of a new teacher created without any.
  final PaymentTerms defaultPaymentTerms;
  final DateTime? updatedAt;
  final String? updatedByName;

  @override
  List<Object?> get props => [autoSettle, defaultPaymentTerms, updatedAt, updatedByName];
}

/// `/api/admin/settings/billing`.
abstract interface class SettingsRepository {
  Future<Result<BillingSettings>> billing();

  /// AutoSettle applies from the next invoice or deposit.
  Future<Result<BillingSettings>> saveBilling({
    required bool autoSettle,
    required PaymentTerms defaultPaymentTerms,
  });
}

class GetBillingSettings implements UseCase<BillingSettings, NoParams> {
  const GetBillingSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<BillingSettings>> call(NoParams params) => _repository.billing();
}

class SaveBillingSettings implements UseCase<BillingSettings, BillingSettings> {
  const SaveBillingSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<BillingSettings>> call(BillingSettings settings) => _repository.saveBilling(
    autoSettle: settings.autoSettle,
    defaultPaymentTerms: settings.defaultPaymentTerms,
  );
}
