import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// One product in the teacher's list: cover, name, subject and level, price, availability.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [product.subject, product.level].whereType<String>().join(' · ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          AppCoverImage(image: context.read<ProductImages>().cover(product), width: 60),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textSecondary.resolveFrom(context),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ProductPrice(price: product.price, style: AppTypography.subheadline),
                    ),
                    ProductAvailabilityBadge(isAvailable: product.isAvailable),
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
