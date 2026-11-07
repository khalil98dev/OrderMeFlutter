import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'helpers/pump_ui.dart';

void main() {
  group('AppSearchField', () {
    testWidgets('reports once, after the user stops typing', (tester) async {
      final queries = <String>[];
      await pumpUi(tester, SizedBox(width: 300, child: AppSearchField(onChanged: queries.add)));

      await tester.enterText(find.byType(CupertinoSearchTextField), 'liv');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(CupertinoSearchTextField), 'livre');
      expect(queries, isEmpty, reason: 'still typing');

      await tester.pump(const Duration(milliseconds: 300));
      expect(queries, ['livre']);
    });

    testWidgets('Enter reports at once, and the same query is not reported twice', (tester) async {
      final queries = <String>[];
      await pumpUi(tester, SizedBox(width: 300, child: AppSearchField(onChanged: queries.add)));

      await tester.enterText(find.byType(CupertinoSearchTextField), 'tp');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 400));

      expect(queries, ['tp']);
    });
  });

  group('AppQuantityStepper', () {
    testWidgets('steps up and down', (tester) async {
      var value = 3;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, setState) =>
              AppQuantityStepper(value: value, onChanged: (next) => setState(() => value = next)),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Augmenter la quantité'));
      await tester.pump();
      expect(value, 4);

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.bySemanticsLabel('Diminuer la quantité'));
        await tester.pump();
      }
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('cannot go below min or above max', (tester) async {
      var changes = 0;
      await pumpUi(tester, AppQuantityStepper(value: 1, min: 1, max: 1, onChanged: (_) => changes++));

      await tester.tap(find.bySemanticsLabel('Diminuer la quantité'));
      await tester.tap(find.bySemanticsLabel('Augmenter la quantité'));

      expect(changes, 0);
    });
  });

  group('AppDateField', () {
    testWidgets('in Arabic, the field and the picker write dates with 0–9', (tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpUi(
        tester,
        SizedBox(
          width: 300,
          child: AppDateField(label: 'من', value: DateTime(2026, 11, 6), onChanged: (_) {}),
        ),
        locale: const Locale('ar'),
      );
      await tester.pumpAndSettle();
      expect(find.text('06/11/2026'), findsOneWidget);

      await tester.tap(find.text('06/11/2026'));
      await tester.pumpAndSettle();
      // The wheel's year and day: Western digits, never ٢٠٢٦ / ٦.
      expect(find.text('2026'), findsWidgets);
      expect(find.text('٢٠٢٦'), findsNothing);
      expect(find.textContaining(RegExp('[٠-٩]')), findsNothing);
    });
  });

  group('AppButton', () {
    testWidgets('ignores taps while loading', (tester) async {
      var taps = 0;
      await pumpUi(tester, AppButton(label: 'Enregistrer', isLoading: true, onPressed: () => taps++));

      await tester.tap(find.text('Enregistrer'));

      expect(taps, 0);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });
}
