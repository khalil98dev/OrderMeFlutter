import 'package:flutter/cupertino.dart';

/// The frame of every tab: an iOS large title that shrinks as the content scrolls.
///
/// [slivers] keeps lists lazy: pass a `SliverList.builder`, never a `Column` of all rows.
class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key, required this.title, required this.slivers});

  final String title;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(largeTitle: Text(title), border: null),
          ...slivers,
        ],
      ),
    );
  }
}
