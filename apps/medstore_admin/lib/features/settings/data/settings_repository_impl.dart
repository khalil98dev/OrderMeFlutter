import 'package:medstore_core/medstore_core.dart';

import '../domain/billing_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._api);

  static const _path = '/api/admin/settings/billing';

  final ApiClient _api;

  @override
  Future<Result<BillingSettings>> billing() => _api.get(_path, decode: billingFromJson);

  @override
  Future<Result<BillingSettings>> saveBilling({
    required bool autoSettle,
    required PaymentTerms defaultPaymentTerms,
  }) => _api.put(
    _path,
    data: {'autoSettle': autoSettle, 'defaultPaymentTerms': defaultPaymentTerms.apiName},
    decode: billingFromJson,
  );

  static BillingSettings billingFromJson(Object? raw) {
    final json = JsonMap.of(raw);
    return BillingSettings(
      autoSettle: json.boolean('autoSettle'),
      defaultPaymentTerms: PaymentTerms.fromApi(json.stringOrNull('defaultPaymentTerms')),
      updatedAt: json.instantOrNull('updatedAt'),
      updatedByName: json.stringOrNull('updatedByName'),
    );
  }
}
