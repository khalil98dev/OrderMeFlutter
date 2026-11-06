import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/soft_card.dart';
import '../cart/cart_bar.dart';
import '../cart/cart_cubit.dart';

/// One book in the teacher's grid: a large cover, name, subject and level, price, and a "+" that adds
/// a copy to the cart (the cover flies into the cart). An unavailable book shows its badge instead.
class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  /// On the cover alone, so the flight takes off from the cover and not from the whole card.
  final _coverKey = GlobalKey();

  void _add() {
    final images = context.read<ProductImages>();
    context.read<CartCubit>().add(widget.product); // state first: the animation is decoration
    final cover = _coverKey.currentContext;
    if (cover == null) return;
    unawaited(
      flyToTarget(
        cover,
        target: cartTarget,
        child: ClipRRect(
          borderRadius: AppRadii.smRadius,
          child: AppCoverImage(image: images.cover(widget.product), width: 56),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final product = widget.product;
    final details = [product.subject, product.level].whereType<String>().join(' · ');
    final inCart = context.select<CartCubit, int>((cart) => cart.state.quantityOf(product.id));

    return SoftCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'product-cover:${product.id}',
                  child: ClipRRect(
                    key: _coverKey,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: ColoredBox(
                      color: AppColors.neutralTint.resolveFrom(context),
                      child: LayoutBuilder(
                        builder: (context, constraints) => AppCoverImage(
                          image: context.read<ProductImages>().cover(product),
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          semanticLabel: product.name,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!product.isAvailable)
                  const PositionedDirectional(
                    top: AppSpacing.xs,
                    start: AppSpacing.xs,
                    child: ProductAvailabilityBadge(isAvailable: false),
                  ),
                if (inCart > 0)
                  PositionedDirectional(
                    top: AppSpacing.xs,
                    end: AppSpacing.xs,
                    child: AppBadge(label: strings.inCart(inCart), tone: AppTone.brand, icon: AppIcons.cart),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxs, AppSpacing.xs, AppSpacing.xxs, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.resolveFrom(context),
                  ),
                ),
                Text(
                  details.isEmpty ? productTypeText(strings, product.type) : details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: ProductPrice(
                        price: product.price,
                        style: AppTypography.subheadline.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (product.isAvailable)
                      AppIconButton(
                        icon: AppIcons.add,
                        label: strings.addToCart,
                        tone: AppTone.brand,
                        filled: true,
                        size: 34,
                        onPressed: _add,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
