import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// A small red counter on the top corner of an icon (unread notifications, copies in the cart).
/// Hidden at zero; "99+" past 99. Pops in when the count changes.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child, this.color});

  final int count;
  final Widget child;

  /// Defaults to the destructive red, the iOS badge color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -6,
          end: -10,
          child: AnimatedSwitcher(
            duration: AppDurations.of(context, AppDurations.micro),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: count <= 0
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(count),
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color ?? AppColors.destructive.resolveFrom(context),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                      border: Border.all(color: AppColors.surface.resolveFrom(context), width: 1.5),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: AppTypography.tabular(
                        AppTypography.caption.copyWith(
                          fontSize: 11,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBrand,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
