import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Reads an amount typed in DZD: "15000", "15 000", "1250,50". Null when it is not a positive number with
/// at most two decimals (the API's rule for money).
num? parseMoney(String text) {
  final cleaned = text.replaceAll(' ', '').replaceAll(' ', '').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;
  final value = num.parse(cleaned);
  return value > 0 ? value : null;
}

/// Empty text is sent as null, not "".
String? optionalText(String text) => text.trim().isEmpty ? null : text.trim();

/// The sentence for a failed save: a known API rule code gets its own sentence, anything else the
/// failure's general text.
String problemText(AppStrings strings, Failure failure) {
  if (failure is ValidationFailure) {
    for (final code in failure.errors.keys) {
      final known = switch (code) {
        'Client.PhoneInvalid' => strings.validationPhone,
        'School.WilayaInvalid' => strings.wilayaInvalid,
        'Wallet.AmountInvalid' || 'Debt.AmountInvalid' => strings.amountInvalid,
        'Order.LinesRequired' || 'Invoice.LinesRequired' => strings.noLines,
        'Statement.PeriodInvalid' || 'Report.PeriodInvalid' => strings.periodTooLong,
        _ => null,
      };
      if (known != null) return known;
    }
    // An unknown rule: the API's own message says more than "check the fields".
    final first = failure.errors.values.expand((messages) => messages).firstOrNull ?? failure.detail;
    if (first != null) return first;
  }
  // A 409 is usually a state rule ("An order that is Ready cannot become Pending"), not a lost race:
  // the server's sentence is the useful one. Only the race has the generic "reload" text.
  if (failure is ConflictFailure && failure.detail != null && !failure.detail!.contains('Concurrency')) {
    return failure.detail!;
  }
  return failureText(strings, failure);
}
