import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'helpers/pump_ui.dart';

enum _Level { primary, secondary }

void main() {
  testWidgets('AppSelectField: picks an option, and "All" reports null', (tester) async {
    _Level? picked = _Level.primary;
    var reported = false;
    await pumpUi(
      tester,
      SizedBox(
        width: 300,
        child: StatefulBuilder(
          builder: (context, setState) => AppSelectField<_Level>(
            label: 'Cycle',
            options: const {_Level.primary: 'Primaire', _Level.secondary: 'Secondaire'},
            value: picked,
            allowNone: true,
            onChanged: (value) => setState(() {
              picked = value;
              reported = true;
            }),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Primaire'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Secondaire').last);
    await tester.pumpAndSettle();
    expect(picked, _Level.secondary);

    await tester.tap(find.text('Secondaire'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tous').last);
    await tester.pumpAndSettle();
    expect(picked, isNull);
    expect(reported, isTrue);
  });

  testWidgets('showAppTextPrompt: confirm stays off while a required text is empty', (tester) async {
    String? result = 'untouched';
    await pumpUi(
      tester,
      Builder(
        builder: (context) => AppButton(
          label: 'Open',
          onPressed: () async => result = await showAppTextPrompt(
            context,
            title: 'Annuler la facture',
            label: 'Motif',
            confirmLabel: 'OK',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler la facture'), findsOneWidget, reason: 'nothing typed: still open');

    await tester.enterText(find.byType(CupertinoTextField), '  Erreur  ');
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, 'Erreur');
  });

  testWidgets('AppTable: builds rows lazily and asks for more near the end', (tester) async {
    var asked = 0;
    await pumpUi(
      tester,
      SizedBox(
        width: 500,
        height: 300,
        child: AppTable(
          columns: const [AppTableColumn('N°', width: 60), AppTableColumn('Nom', flex: 2)],
          rowCount: 100,
          hasMore: true,
          onEndReached: () => asked++,
          cells: (context, index) => [Text('$index'), Text('Ligne $index')],
        ),
      ),
    );

    expect(find.text('Ligne 0'), findsOneWidget);
    expect(find.text('Ligne 99'), findsNothing, reason: 'rows far below are not built');

    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pump();
    expect(asked, greaterThan(0));
  });

  testWidgets('AppPageHeader: a back button only for sub-pages', (tester) async {
    var back = 0;
    await pumpUi(
      tester,
      SizedBox(
        width: 500,
        child: AppPageHeader(title: 'Commande', onBack: () => back++),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Retour'));
    expect(back, 1);
  });
}
