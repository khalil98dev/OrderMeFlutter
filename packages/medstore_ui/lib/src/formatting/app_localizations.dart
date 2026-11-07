import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';

/// Every localizations delegate the apps need, for `CupertinoApp.localizationsDelegates`.
///
/// It is [AppStrings.localizationsDelegates] with one addition placed first: the
/// Cupertino strings for Arabic with Western digits (0–9). Flutter's Arabic date picker writes days
/// and years in Arabic-Indic digits (٠١٢…); the apps follow the Algerian habit of 0–9, like
/// [AppDateFormat] and [MoneyFormat]. For each type, the first delegate that supports the locale
/// wins, so French still comes from Flutter.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  _LatinDigitsArabicCupertino(),
  ...AppStrings.localizationsDelegates,
];

/// Flutter's Arabic Cupertino translations, built with date and number formats that keep 0–9.
class _LatinDigitsArabicCupertino extends LocalizationsDelegate<CupertinoLocalizations> {
  const _LatinDigitsArabicCupertino();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ar';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    await initializeDateFormatting('ar');
    DateFormat latin(DateFormat format) => format..useNativeDigits = false;
    return CupertinoLocalizationAr(
      fullYearFormat: latin(DateFormat.y('ar')),
      dayFormat: latin(DateFormat.d('ar')),
      weekdayFormat: latin(DateFormat.E('ar')),
      mediumDateFormat: latin(DateFormat.MMMEd('ar')),
      singleDigitHourFormat: latin(DateFormat('HH', 'ar')),
      singleDigitMinuteFormat: latin(DateFormat.m('ar')),
      doubleDigitMinuteFormat: latin(DateFormat('mm', 'ar')),
      singleDigitSecondFormat: latin(DateFormat.s('ar')),
      // Algeria's Arabic number format already uses 0–9 (see MoneyFormat).
      decimalFormat: NumberFormat.decimalPattern('ar_DZ'),
    );
  }

  @override
  bool shouldReload(_LatinDigitsArabicCupertino old) => false;
}
