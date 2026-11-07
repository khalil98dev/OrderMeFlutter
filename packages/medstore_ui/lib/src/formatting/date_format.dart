import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// Dates the way each language writes them, with Western digits in Arabic (the Algerian habit).
///
/// ```dart
/// AppDateFormat.day(invoice.dueDate, locale);        // "30/11/2026"
/// AppDateFormat.dateTime(order.placedAt, locale);    // "04/11/2026 21:34"
/// AppDateFormat.month(DateTime(2026, 11), locale);   // "novembre 2026"
/// ```
///
/// Instants from the API are UTC; they are shown in the device's time zone.
abstract final class AppDateFormat {
  static String _tag(Locale locale) => locale.languageCode == 'ar' ? 'ar_DZ' : 'fr_DZ';

  /// intl has no date data for `ar_DZ` and falls back to `ar`, whose digits are Arabic-Indic
  /// (٠١٢…): turning native digits off keeps 0–9, as amounts already do.
  static DateFormat _format(String pattern, Locale locale) =>
      DateFormat(pattern, _tag(locale))..useNativeDigits = false;

  static String day(DateTime date, Locale locale) => _format('dd/MM/yyyy', locale).format(date);

  static String dateTime(DateTime instant, Locale locale) =>
      _format('dd/MM/yyyy HH:mm', locale).format(instant.toLocal());

  static String month(DateTime date, Locale locale) =>
      (DateFormat.yMMMM(_tag(locale))..useNativeDigits = false).format(date);
}
