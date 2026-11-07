import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/count_badge.dart';
import 'cart_cubit.dart';

/// Where products fly to when they are added. Attached to the one [CartBar] the shell shows, so a
/// flight from the product list or a product page always finds it.
final cartTarget = GlobalKey<AppBounceTargetState>();

/// The floating cart above the tab bar: a round button, white while the cart is empty, blue with the
/// count of copies once something is in it. Each item that lands in it makes it swell to 1.5× and
/// settle back. Opens the cart.
class CartBar extends StatelessWidget {
  const CartBar({super.key});

  static const route = '/cart';

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final copies = context.select<CartCubit, int>((cart) => cart.state.copies);
    final accent = AppColors.accent.resolveFrom(context);
    final filled = copies > 0;

    return Semantics(
      button: true,
      label: filled ? '${strings.viewCart}, ${strings.copiesCount(copies)}' : strings.viewCart,
      excludeSemantics: true,
      child: AppBounceTarget.pop(
        key: cartTarget,
        child: Pressable(
          onTap: () => context.push(route),
          borderRadius: const BorderRadius.all(Radius.circular(_size / 2)),
          child: AnimatedContainer(
            duration: AppDurations.of(context, AppDurations.expand),
            curve: AppDurations.easeOut,
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: filled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentFill.resolveFrom(context),
                        AppColors.accentDeep.resolveFrom(context),
                      ],
                    )
                  : null,
              color: filled ? null : AppColors.surface.resolveFrom(context),
              boxShadow: [
                BoxShadow(
                  color: (filled ? accent : const Color(0xFF12131A)).withValues(alpha: filled ? 0.35 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CountBadge(
                count: copies,
                child: Icon(AppIcons.cart, size: 26, color: filled ? AppColors.onBrand : accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
