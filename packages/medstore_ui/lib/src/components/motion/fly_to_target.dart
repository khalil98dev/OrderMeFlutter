import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';

import '../../tokens/app_metrics.dart';
import 'app_bounce_target.dart';

/// Flies a copy of [child] from the widget that owns [sourceContext] to [target] along a curved arc,
/// shrinking as it goes, then bounces the target. Completes when the flight has landed.
///
/// The flyer is drawn in the root [Overlay], so it passes over app bars, lists and tab bars, and it
/// ignores taps. With "reduce motion" on there is no flight: the target just updates (no bounce).
///
/// [sourceContext] must be the context of the thing that takes off (wrap the product image in a
/// [Builder] and pass that context), not the screen's context, or the flight starts from the screen.
///
/// ```dart
/// Builder(
///   builder: (imageContext) => AppButton(
///     label: strings.addToCart,
///     onPressed: () async {
///       cubit.add(product);                       // update state first: never wait for the animation
///       await flyToTarget(imageContext, target: _cartKey, child: ProductImage(product));
///     },
///   ),
/// );
/// ```
Future<void> flyToTarget(
  BuildContext sourceContext, {
  required GlobalKey<AppBounceTargetState> target,
  required Widget child,
  Size size = const Size.square(56),
  double arcHeight = 120,
  Duration duration = AppDurations.flight,
}) async {
  // 1. Measure both ends now, synchronously, while both widgets are known to be on screen.
  final overlay = Overlay.maybeOf(sourceContext, rootOverlay: true);
  final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
  final sourceBox = sourceContext.findRenderObject() as RenderBox?;
  final targetBox = target.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null ||
      overlayBox == null ||
      sourceBox == null ||
      !sourceBox.attached ||
      targetBox == null ||
      !targetBox.attached) {
    return; // One end is off screen: skip the flourish, the state change already happened.
  }

  // Positions are taken relative to the overlay, not the screen, so it also works inside a
  // split view, a sheet or a desktop window with a sidebar.
  final start = sourceBox.localToGlobal(sourceBox.size.center(Offset.zero), ancestor: overlayBox);
  final end = targetBox.localToGlobal(targetBox.size.center(Offset.zero), ancestor: overlayBox);

  final effective = AppDurations.of(sourceContext, duration);
  if (effective == Duration.zero) return;

  // 2. The curve: a quadratic Bézier. The control point sits above the higher of the two ends,
  //    halfway across, so the item rises before it drops into the target.
  final control = Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy) - arcHeight);

  final controller = AnimationController(vsync: overlay, duration: effective);
  final progress = CurvedAnimation(parent: controller, curve: AppDurations.standard);

  final entry = OverlayEntry(
    builder: (_) => AnimatedBuilder(
      animation: progress,
      child: IgnorePointer(
        child: SizedBox.fromSize(size: size, child: child),
      ),
      builder: (_, flyer) {
        final t = progress.value;
        // "Offset.lerp twice" (de Casteljau): lerp along both legs, then lerp between the results.
        final a = Offset.lerp(start, control, t)!;
        final b = Offset.lerp(control, end, t)!;
        final point = Offset.lerp(a, b, t)!;
        return Positioned(
          left: point.dx - size.width / 2,
          top: point.dy - size.height / 2,
          child: Opacity(
            opacity: t < 0.85 ? 1 : (1 - t) / 0.15, // fade only in the last moment, inside the target
            child: Transform.scale(scale: lerpDouble(1, 0.3, t)!, child: flyer),
          ),
        );
      },
    ),
  );

  // 3. Insert, run, and clean up exactly once. THE remove() TRAP: an OverlayEntry must be removed
  //    once and only once. Removing it from a status listener *and* from dispose, or calling remove()
  //    on an entry that was never inserted, throws; forgetting it leaves a frozen ghost on screen.
  //    One owner (this function) removes it, in `finally`, so an error or a cancelled ticker can't
  //    skip the cleanup.
  overlay.insert(entry);
  try {
    await controller.forward().orCancel;
  } on TickerCanceled {
    // The overlay went away mid-flight (screen popped); the finally block still cleans up.
  } finally {
    entry.remove();
    entry.dispose();
    progress.dispose();
    controller.dispose();
  }

  // 4. Landed: bounce the target (it checks `mounted` itself).
  target.currentState?.bounce();
}
