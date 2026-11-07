import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/soft_card.dart';
import '../cart/cart_bar.dart';
import '../cart/cart_cubit.dart';

/// One book: a large cover on a tinted backdrop, its price and details, and a bottom bar to choose
/// the copies and add them to the cart (the cover flies into the cart).
///
/// Expects a [ProductDetailCubit] above it (the route provides one, seeded with the product from the
/// list so the page shows at once, then refreshed).
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = context.watch<ProductDetailCubit>().state;
    final product = state.product;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(product?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        previousPageTitle: strings.navProducts,
        border: null,
      ),
      child: SafeArea(
        child: AppLoadView(
          isLoading: state.isLoading,
          hasData: product != null,
          failure: state.failure,
          onRetry: context.read<ProductDetailCubit>().load,
          loading: const Center(child: CupertinoActivityIndicator()),
          empty: const SizedBox.shrink(),
          builder: (context) => _ProductDetails(product: product!),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatefulWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  State<_ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<_ProductDetails> {
  final _coverKey = GlobalKey();
  var _copies = 1;

  void _add() {
    final images = context.read<ProductImages>();
    context.read<CartCubit>().add(widget.product, quantity: _copies);
    showAppToast(
      context,
      AppStrings.of(context).inCart(context.read<CartCubit>().state.quantityOf(widget.product.id)),
      tone: AppTone.success,
    );
    final cover = _coverKey.currentContext;
    if (cover != null) {
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
    setState(() => _copies = 1);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final primary = AppColors.textPrimary.resolveFrom(context);
    final product = widget.product;
    final details = [
      if (product.code case final code?) (strings.fieldCode, code),
      if (product.subject case final subject?) (strings.fieldSubject, subject),
      if (product.level case final level?) (strings.fieldLevel, level),
      if (product.pageCount case final pages?) (strings.fieldPageCount, strings.pageCount(pages)),
      (strings.fieldType, productTypeText(strings, product.type)),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            // Room for the floating cart, which sits above the add bar.
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accentTint.resolveFrom(context),
                      AppColors.canvas.resolveFrom(context),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'product-cover:${product.id}',
                    child: DecoratedBox(
                      key: _coverKey,
                      decoration: const BoxDecoration(
                        borderRadius: AppRadii.mdRadius,
                        boxShadow: [
                          BoxShadow(color: Color(0x3312131A), blurRadius: 30, offset: Offset(0, 14)),
                        ],
                      ),
                      child: AppCoverImage(
                        image: context.read<ProductImages>().cover(product),
                        width: 190,
                        semanticLabel: product.name,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        AppBadge(label: productTypeText(strings, product.type), tone: AppTone.accent),
                        ProductAvailabilityBadge(isAvailable: product.isAvailable),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(product.name, style: AppTypography.title1.copyWith(color: primary)),
                    const SizedBox(height: AppSpacing.xs),
                    ProductPrice(price: product.price, style: AppTypography.title3, perCopy: true),
                    if (!product.isAvailable) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppMessage(text: strings.productUnavailableNotice, tone: AppTone.warning),
                    ],
                    if (product.description case final description?) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        description,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary.resolveFrom(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      child: Column(
                        children: [
                          for (final (index, (label, value)) in details.indexed) ...[
                            if (index > 0)
                              Container(height: 0.5, color: AppColors.separator.resolveFrom(context)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Text(
                                    label,
                                    style: AppTypography.subheadline.copyWith(
                                      color: AppColors.textSecondary.resolveFrom(context),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      value,
                                      textAlign: TextAlign.end,
                                      style: AppTypography.subheadline.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (product.isAvailable)
          _AddBar(copies: _copies, onCopies: (value) => setState(() => _copies = value), onAdd: _add),
      ],
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({required this.copies, required this.onCopies, required this.onAdd});

  final int copies;
  final ValueChanged<int> onCopies;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        boxShadow: const [BoxShadow(color: Color(0x1412131A), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            AppQuantityStepper(value: copies, max: CartCubit.maxCopies, onChanged: onCopies),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(label: strings.addToCart, icon: AppIcons.cart, expand: true, onPressed: onAdd),
            ),
          ],
        ),
      ),
    );
  }
}
