import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';

/// A grey placeholder in the shape of content that is still loading.
///
/// ```dart
/// AppSkeletonPulse(
///   child: Column(children: [AppSkeleton(width: 180), AppSkeleton(width: 120, height: 12)]),
/// )
/// ```
///
/// Skeletons are still on their own; wrap a whole group in one [AppSkeletonPulse] so the group breathes
/// with a single animation (one controller for a whole list, not one per line).
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadii.xs,
    this.circle = false,
  });

  /// A round placeholder for an avatar.
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  /// Null fills the available width.
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutralTint.resolveFrom(context),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Fades its skeletons in and out together. Still when the user asked for reduced motion.
class AppSkeletonPulse extends StatefulWidget {
  const AppSkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<AppSkeletonPulse> createState() => _AppSkeletonPulseState();
}

class _AppSkeletonPulseState extends State<AppSkeletonPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.45,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.of(context).loading,
      excludeSemantics: true,
      // RepaintBoundary: the fade repaints only the skeleton, not the page around it.
      child: RepaintBoundary(
        child: FadeTransition(opacity: _controller, child: widget.child),
      ),
    );
  }
}

/// A ready-made loading list: [count] rows shaped like `AppListTile`s with an avatar.
///
/// In a box shorter than [count] rows, the extra rows are cut off at the bottom (like a real list
/// that continues below), never an overflow error.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonPulse(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // clips without letting the user scroll a placeholder
        child: _rows(),
      ),
    );
  }

  Widget _rows() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const AppSkeleton.circle(size: 36),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Varying widths look like real text instead of a grid of bars.
                      FractionallySizedBox(widthFactor: i.isEven ? 0.7 : 0.55, child: const AppSkeleton()),
                      const SizedBox(height: 6),
                      const FractionallySizedBox(widthFactor: 0.35, child: AppSkeleton(height: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
