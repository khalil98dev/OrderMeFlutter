import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_ui/medstore_ui.dart';

void main() {
  group('MoneyFormat.dzd', () {
    //   is the narrow no-break space French uses between thousands;   joins number and symbol.
    test('French: spaces between thousands, "DA" after', () {
      expect(MoneyFormat.dzd(1234567, const Locale('fr')), '1 234 567 DA');
    });

    test('Arabic: Algerian convention, Western digits, "د.ج" after', () {
      expect(MoneyFormat.dzd(1234567, const Locale('ar')), '1.234.567 د.ج');
    });

    test('whole dinars by default, decimals on request', () {
      expect(MoneyFormat.dzd(99.6, const Locale('fr')), '100 DA');
      expect(MoneyFormat.dzd(99.5, const Locale('fr'), decimals: 2), '99,50 DA');
    });
  });

  group('AppAvatar.initialsOf', () {
    test('first letters of the first two words', () {
      expect(AppAvatar.initialsOf('amina benali'), 'AB');
      expect(AppAvatar.initialsOf('  Karim   Ait   Said '), 'KA');
    });

    test('one word gives one letter; Arabic works', () {
      expect(AppAvatar.initialsOf('prof.amina'), 'P');
      expect(AppAvatar.initialsOf('أمينة بن علي'), 'أب');
    });

    test('an empty name gives no initials', () {
      expect(AppAvatar.initialsOf('   '), '');
    });
  });
}
