import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import 'pressable.dart';

/// A white (dark mode: elevated grey) card with a light border and a soft shadow, the base of every
/// grouped block.
///
/// ```dart
/// AppCard(child: ...)
/// AppCard(onTap: () => context.push('/orders/${order.id}'), child: OrderSummary(order))
/// ```
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = AppSpacing.card, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Makes the whole card tappable, with hover and press feedback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: AppRadii.mdRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.resolveFrom(context),
          borderRadius: AppRadii.mdRadius,
          border: Border.all(color: AppColors.border.resolveFrom(context)),
          boxShadow: AppShadows.of(context, AppShadows.card),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
