import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/app/shell/section_transition.dart';

/// A section with state of its own: how many times it was tapped.
class _Counter extends StatefulWidget {
  const _Counter(this.name);

  final String name;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _taps++),
    child: Text('${widget.name} $_taps', textDirection: TextDirection.ltr),
  );
}

void main() {
  Widget sections(int index) => Directionality(
    textDirection: TextDirection.ltr,
    child: SectionTransition(currentIndex: index, children: const [_Counter('orders'), _Counter('wallet')]),
  );

  double opacityOf(WidgetTester tester, String text) => tester
      .widget<FadeTransition>(
        find.ancestor(of: find.textContaining(text), matching: find.byType(FadeTransition)).first,
      )
      .opacity
      .value;

  testWidgets('switching cross-fades, then the old section goes offstage', (tester) async {
    await tester.pumpWidget(sections(0));
    expect(find.text('orders 0'), findsOneWidget);
    expect(find.text('wallet 0'), findsNothing, reason: 'offstage until selected');

    await tester.pumpWidget(sections(1));
    await tester.pump(SectionTransition.duration ~/ 2);
    // Both on screen, half way: the new one coming in, the old one going out.
    expect(opacityOf(tester, 'wallet'), inExclusiveRange(0, 1));
    expect(opacityOf(tester, 'orders'), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'wallet'), 1);
    expect(find.text('orders 0'), findsNothing, reason: 'faded out, then offstage');
  });

  testWidgets('a section keeps its state when the user comes back to it', (tester) async {
    await tester.pumpWidget(sections(0));
    await tester.tap(find.text('orders 0'));
    await tester.pump();
    expect(find.text('orders 1'), findsOneWidget);

    await tester.pumpWidget(sections(1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(sections(0));
    await tester.pumpAndSettle();
    expect(find.text('orders 1'), findsOneWidget);
  });

  testWidgets('with reduce motion, the switch is instant', (tester) async {
    Widget still(int index) =>
        MediaQuery(data: const MediaQueryData(disableAnimations: true), child: sections(index));
    await tester.pumpWidget(still(0));
    await tester.pumpWidget(still(1));
    await tester.pump();
    expect(find.text('orders 0'), findsNothing);
    expect(opacityOf(tester, 'wallet'), 1);
  });
}
