import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// Formats Algerian dinar amounts the way each language writes them.
///
/// ```dart
/// MoneyFormat.dzd(12500, const Locale('fr')); // "12 500 DA"
/// MoneyFormat.dzd(12500, const Locale('ar')); // "12.500 د.ج"
/// ```
///
/// - Prints are priced in whole dinars, so there are no decimals unless asked for.
/// - Arabic uses the Algerian convention (Western digits, dot between thousands).
/// - Number and symbol are joined by a no-break space, so an amount never wraps onto two lines.
abstract final class MoneyFormat {
  static const _noBreakSpace = ' ';

  static String dzd(num amount, Locale locale, {int decimals = 0}) {
    final arabic = locale.languageCode == 'ar';
    final number = NumberFormat.decimalPatternDigits(
      locale: arabic ? 'ar_DZ' : 'fr_DZ',
      decimalDigits: decimals,
    ).format(amount);
    final symbol = arabic ? 'د.ج' : 'DA';
    return '$number$_noBreakSpace$symbol';
  }
}
