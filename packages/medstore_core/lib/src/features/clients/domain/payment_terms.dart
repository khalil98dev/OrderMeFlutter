/// When a teacher's invoices fall due. Set per teacher by the MedStore team; the teacher sees theirs.
enum PaymentTerms {
  immediate('Immediate'),
  endOfMonth('EndOfMonth'),
  endOfYear('EndOfYear');

  const PaymentTerms(this.apiName);

  final String apiName;

  static PaymentTerms fromApi(String? value) =>
      values.firstWhere((terms) => terms.apiName == value, orElse: () => immediate);

  /// Null when the field was hidden from this user (a secured field) or not set.
  static PaymentTerms? fromApiOrNull(String? value) => value == null ? null : fromApi(value);
}
