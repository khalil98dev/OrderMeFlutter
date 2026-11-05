import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'helpers/pump_ui.dart';

void main() {
  const flyer = SizedBox.square(key: ValueKey('flyer'), dimension: 56);
  final flyerFinder = find.byKey(const ValueKey('flyer'));

  late GlobalKey<AppBounceTargetState> cartKey;
  late GlobalKey sourceKey;

  setUp(() {
    cartKey = GlobalKey<AppBounceTargetState>();
    sourceKey = GlobalKey();
  });

  /// A cart at the top end and a product cover at the bottom start.
  Widget scene({bool reduceMotion = false, bool showCart = true}) => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: SizedBox(
        width: 400,
        height: 500,
        child: Stack(
          children: [
            if (showCart)
              Positioned(
                top: 0,
                right: 0,
                child: AppBounceTarget(key: cartKey, child: const SizedBox.square(dimension: 40)),
              ),
            Positioned(left: 0, bottom: 0, child: SizedBox.square(key: sourceKey, dimension: 56)),
          ],
        ),
      ),
    ),
  );

  double cartScale(WidgetTester tester) => tester
      .widget<ScaleTransition>(
        find.descendant(of: find.byType(AppBounceTarget), matching: find.byType(ScaleTransition)),
      )
      .scale
      .value;

  testWidgets('flies along a curve, lands, leaves nothing behind and bounces the cart', (tester) async {
    await pumpUi(tester, scene());
    final start = tester.getCenter(find.byKey(sourceKey));
    final end = tester.getCenter(find.byType(AppBounceTarget));

    var landed = false;
    unawaited(
      flyToTarget(sourceKey.currentContext!, target: cartKey, child: flyer).then((_) => landed = true),
    );
    await tester.pump();
    expect(flyerFinder, findsOneWidget);

    await tester.pump(AppDurations.flight * 0.5);
    expect(
      tester.getCenter(flyerFinder).dy,
      lessThan((start.dy + end.dy) / 2 - 40),
      reason: 'halfway, the flyer is well above the straight line: the path is curved',
    );
    expect(tester.getCenter(flyerFinder).dx, inExclusiveRange(start.dx, end.dx));

    await tester.pump(AppDurations.flight * 0.5 + const Duration(milliseconds: 20));
    expect(landed, isTrue);
    expect(flyerFinder, findsNothing);

    await tester.pump(AppDurations.bounce * 0.3);
    expect(cartScale(tester), greaterThan(1.05), reason: 'the cart grows when the item lands');
    await tester.pumpAndSettle();
    expect(cartScale(tester), 1);
  });

  testWidgets('five fast taps: five flights, no leftover image', (tester) async {
    await pumpUi(tester, scene());
    for (var i = 0; i < 5; i++) {
      unawaited(flyToTarget(sourceKey.currentContext!, target: cartKey, child: flyer));
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(flyerFinder, findsNWidgets(5));
    await tester.pumpAndSettle();
    expect(flyerFinder, findsNothing);
  });

  testWidgets('reduce motion: no flight and no bounce', (tester) async {
    await pumpUi(tester, scene(reduceMotion: true));
    await flyToTarget(sourceKey.currentContext!, target: cartKey, child: flyer);
    await tester.pump();
    expect(flyerFinder, findsNothing);
    expect(cartScale(tester), 1);
  });

  testWidgets('the cart disappears mid-flight: the flight ends cleanly, no error, nothing left', (
    tester,
  ) async {
    await pumpUi(tester, scene());
    unawaited(flyToTarget(sourceKey.currentContext!, target: cartKey, child: flyer));
    await tester.pump(AppDurations.flight * 0.5);

    await pumpUi(tester, scene(showCart: false));
    await tester.pumpAndSettle();
    expect(flyerFinder, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cart not on screen: returns at once without drawing anything', (tester) async {
    await pumpUi(tester, scene(showCart: false));
    await flyToTarget(sourceKey.currentContext!, target: cartKey, child: flyer);
    await tester.pump();
    expect(flyerFinder, findsNothing);
  });
}
