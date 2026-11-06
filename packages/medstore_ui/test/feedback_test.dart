import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'helpers/pump_ui.dart';

void main() {
  group('AppLoadView', () {
    Widget view({required bool isLoading, required bool hasData, Failure? failure}) => AppLoadView(
      isLoading: isLoading,
      hasData: hasData,
      failure: failure,
      onRetry: () {},
      empty: const Text('empty'),
      builder: (_) => const Text('data'),
    );

    testWidgets('data wins over loading and failure (cached data stays on screen)', (tester) async {
      await pumpUi(tester, view(isLoading: true, hasData: true, failure: const NetworkFailure()));
      expect(find.text('data'), findsOneWidget);
    });

    testWidgets('no data and loading: a skeleton', (tester) async {
      await pumpUi(tester, view(isLoading: true, hasData: false));
      expect(find.byType(AppSkeletonList), findsOneWidget);
    });

    testWidgets('no data and a failure: the error with "Try again"', (tester) async {
      await pumpUi(tester, view(isLoading: false, hasData: false, failure: const NetworkFailure()));
      expect(find.text('Une erreur est survenue'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('a cancelled request is not an error: the empty state shows', (tester) async {
      await pumpUi(tester, view(isLoading: false, hasData: false, failure: const CancelledFailure()));
      expect(find.text('empty'), findsOneWidget);
    });
  });

  group('showAppConfirmDialog', () {
    Future<bool?> openAndAnswer(WidgetTester tester, String answer) async {
      bool? result;
      await pumpUi(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'open',
            onPressed: () async => result = await showAppConfirmDialog(
              context,
              title: 'Annuler la commande ?',
              confirmLabel: 'Oui, annuler',
              destructive: true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('confirm gives true', (tester) async {
      expect(await openAndAnswer(tester, 'Oui, annuler'), isTrue);
    });

    testWidgets('cancel gives false', (tester) async {
      expect(await openAndAnswer(tester, 'Annuler'), isFalse);
    });
  });

  testWidgets('showAppToast shows the message, then hides it', (tester) async {
    await pumpUi(
      tester,
      Builder(
        builder: (context) =>
            AppButton(label: 'save', onPressed: () => showAppToast(context, 'Commande enregistrée')),
      ),
    );

    await tester.tap(find.text('save'));
    await tester.pump();
    expect(find.text('Commande enregistrée'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Commande enregistrée'), findsNothing);
  });

  testWidgets('AppListTile shows a chevron only when tappable', (tester) async {
    await pumpUi(
      tester,
      AppSection(
        children: [
          AppListTile(title: 'Tappable', onTap: () {}),
          const AppListTile(title: 'Static'),
        ],
      ),
    );
    expect(find.byIcon(AppIcons.forward), findsOneWidget);
  });
}
