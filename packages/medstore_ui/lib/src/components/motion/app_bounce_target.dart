import 'dart:math' as math;

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
///
/// // A smooth swell to 1.5× and back, for a target that should stand out more (the floating cart).
/// AppBounceTarget.pop(key: _cartKey, peak: 1.5, child: cartButton);
/// ```
class AppBounceTarget extends StatefulWidget {
  const AppBounceTarget({super.key, required this.child}) : peak = null;

  /// Grows smoothly to [peak] times its size, then eases back to 1, with no squash.
  const AppBounceTarget.pop({super.key, required this.child, this.peak = 1.5});

  final Widget child;

  /// The size reached by a pop; null plays the grow–squash–settle bounce.
  final double? peak;

  @override
  State<AppBounceTarget> createState() => AppBounceTargetState();
}

class AppBounceTargetState extends State<AppBounceTarget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.peak == null ? AppDurations.bounce : AppDurations.pop,
  );

  /// Share of a pop spent growing; the rest eases back.
  static const _growShare = 0.4;

  late final Animation<double> _scale = switch (widget.peak) {
    // Grow, squash, settle: reads as "something landed in here".
    null => TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
    // Swell and settle, each half on its own ease, so both ends are soft.
    final peak => TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: peak).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: _growShare * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: peak, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: (1 - _growShare) * 100,
      ),
    ]).animate(_controller),
  };

  /// Plays the bounce from the start (a second item landing mid-bounce restarts it). A pop still
  /// growing just carries on, so fast taps never snap it back to 1. Does nothing when the user asked
  /// to reduce motion.
  void bounce() {
    if (!mounted || AppDurations.of(context, _controller.duration!) == Duration.zero) return;
    if (widget.peak != null && _controller.isAnimating && _controller.value < _growShare) return;
    _controller.forward(from: widget.peak == null ? 0 : _resumeFrom);
  }

  /// Where to restart a pop that is shrinking back: the point of the grow that has the same size, so
  /// it swells again from where it is instead of jumping.
  double get _resumeFrom {
    if (!_controller.isAnimating) return 0;
    final size = _scale.value;
    final peak = widget.peak!;
    // Inverse of easeOutCubic on the grow half.
    final eased = ((size - 1) / (peak - 1)).clamp(0.0, 1.0);
    final t = 1 - _cbrt(1 - eased);
    return t * _growShare;
  }

  static double _cbrt(double x) => x <= 0 ? 0 : math.pow(x, 1 / 3).toDouble();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}
