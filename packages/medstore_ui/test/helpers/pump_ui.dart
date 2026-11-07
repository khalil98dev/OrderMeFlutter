import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Shows [child] the way the apps do: our Cupertino theme and the ar/fr strings (French by default).
Future<void> pumpUi(WidgetTester tester, Widget child, {Locale locale = const Locale('fr')}) {
  return tester.pumpWidget(
    CupertinoApp(
      theme: AppTheme.cupertino,
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      home: CupertinoPageScaffold(child: Center(child: child)),
    ),
  );
}
