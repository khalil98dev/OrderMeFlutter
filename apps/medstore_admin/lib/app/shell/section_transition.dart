import 'package:flutter/widgets.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Holds every sidebar section's navigator, like an `IndexedStack`, and cross-fades between them
/// when the selection changes: the new section fades in while rising 8 px, the old one fades out.
///
/// Every section stays mounted (its scroll position, filters and pushed pages survive), and every
/// child always gets the same wrappers, so switching never rebuilds a section's state. Sections that
/// are not shown are offstage, with their tickers paused. With "reduce motion" the switch is instant.
class SectionTransition extends StatefulWidget {
  const SectionTransition({super.key, required this.currentIndex, required this.children});

  final int currentIndex;
  final List<Widget> children;

  static const duration = Duration(milliseconds: 220);

  @override
  State<SectionTransition> createState() => _SectionTransitionState();
}

class _SectionTransitionState extends State<SectionTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SectionTransition.duration, value: 1)
        ..addStatusListener((status) {
          // The old section is fully faded out: take it offstage.
          if (status == AnimationStatus.completed && _previous != null) setState(() => _previous = null);
        });

  late final Animation<double> _in = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<double> _out = ReverseAnimation(
    CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
  );
  late final Animation<Offset> _rise = Tween(begin: const Offset(0, 8), end: Offset.zero).animate(_in);

  /// The section being faded out, while it is.
  int? _previous;

  static const _still = AlwaysStoppedAnimation<double>(1);
  static const _noRise = AlwaysStoppedAnimation<Offset>(Offset.zero);

  @override
  void didUpdateWidget(SectionTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    if (AppDurations.of(context, SectionTransition.duration) == Duration.zero) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    _previous = oldWidget.currentIndex;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [for (final (index, child) in widget.children.indexed) _section(index, child)],
    );
  }

  /// The same wrappers for every section, whatever its role, so none is ever rebuilt.
  Widget _section(int index, Widget child) {
    final current = index == widget.currentIndex;
    final leaving = index == _previous;
    final visible = current || leaving;
    return KeyedSubtree(
      key: ValueKey(index),
      child: Offstage(
        offstage: !visible,
        child: TickerMode(
          enabled: visible,
          child: IgnorePointer(
            ignoring: !current,
            child: FadeTransition(
              opacity: current ? _in : (leaving ? _out : _still),
              child: AnimatedBuilder(
                animation: current ? _rise : _noRise,
                builder: (context, child) =>
                    Transform.translate(offset: (current ? _rise : _noRise).value, child: child),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
