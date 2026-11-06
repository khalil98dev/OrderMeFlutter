import 'package:flutter/cupertino.dart';

import '../../tokens/app_metrics.dart';

/// Wraps the widget something flies into (the cart icon, a basket badge) and makes it bounce when
/// [AppBounceTargetState.bounce] is called.
///
/// Give it a `GlobalKey<AppBounceTargetState>`: the same key tells [flyToTarget] where to land and
/// lets it trigger the bounce on arrival.
///
/// ```dart
/// final _cartKey = GlobalKey<AppBounceTargetState>();
///
/// AppBounceTarget(key: _cartKey, child: const Icon(AppIcons.cart));
/// ```
class AppBounceTarget extends StatefulWidget {
  const AppBounceTarget({super.key, required this.child});

  final Widget child;

  @override
  State<AppBounceTarget> createState() => AppBounceTargetState();
}

class AppBounceTargetState extends State<AppBounceTarget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.bounce,
  );

  /// Grow, squash, settle: reads as "something landed in here".
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.25), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 1), weight: 20),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  /// Plays the bounce from the start (a second item landing mid-bounce restarts it). Does nothing
  /// when the user asked to reduce motion.
  void bounce() {
    if (!mounted || AppDurations.of(context, _controller.duration!) == Duration.zero) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}
