import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/count_badge.dart';
import 'cart_cubit.dart';

/// Where products fly to when they are added. Attached to the one [CartBar] the shell shows, so a
/// flight from the product list or a product page always finds it.
final cartTarget = GlobalKey<AppBounceTargetState>();

/// The floating cart above the tab bar: a round button while the cart is empty, a pill with the
/// copies and the total once something is in it. Opens the cart.
class CartBar extends StatelessWidget {
  const CartBar({super.key});

  static const route = '/cart';

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cart = context.watch<CartCubit>().state;
    final brand = AppColors.brand.resolveFrom(context);
    final expanded = !cart.isEmpty;

    final icon = AppBounceTarget(
      key: cartTarget,
      child: CountBadge(
        count: cart.copies,
        color: expanded ? AppColors.textPrimary.resolveFrom(context) : null,
        child: Icon(
          expanded ? CupertinoIcons.cart_fill : CupertinoIcons.cart,
          size: 24,
          color: expanded ? AppColors.onBrand : brand,
        ),
      ),
    );

    return Semantics(
      button: true,
      label: strings.viewCart,
      child: Pressable(
        onTap: () => context.push(route),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: AnimatedContainer(
          duration: AppDurations.of(context, AppDurations.expand),
          curve: AppDurations.easeOut,
          height: 58,
          padding: EdgeInsets.symmetric(horizontal: expanded ? AppSpacing.lg : 17),
          decoration: BoxDecoration(
            gradient: expanded
                ? LinearGradient(colors: [brand, AppColors.brandDeep.resolveFrom(context)])
                : null,
            color: expanded ? null : AppColors.surface.resolveFrom(context),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            boxShadow: [
              BoxShadow(
                color: (expanded ? brand : const Color(0xFF12131A)).withValues(alpha: expanded ? 0.35 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: AppDurations.of(context, AppDurations.expand),
            curve: AppDurations.easeOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (expanded) ...[
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.viewCart,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headline.copyWith(color: AppColors.onBrand),
                        ),
                        Text(
                          strings.copiesCount(cart.copies),
                          maxLines: 1,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onBrand.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (cart.total case final total?) ...[
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      MoneyFormat.dzd(total, locale),
                      style: AppTypography.tabular(AppTypography.headline.copyWith(color: AppColors.onBrand)),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
