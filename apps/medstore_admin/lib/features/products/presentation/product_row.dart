import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// One product in the admin list, laid out in columns:
/// cover · name and code · teacher · type · price · availability · actions.
///
/// Tapping the row edits the product.
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, required this.onEdit, required this.onDelete});

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final primary = AppColors.textPrimary.resolveFrom(context);
    final secondary = AppColors.textSecondary.resolveFrom(context);
    final classInfo = [product.subject, product.level].whereType<String>().join(' · ');

    return Pressable(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            AppCoverImage(image: context.read<ProductImages>().cover(product), width: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 3,
              child: _TwoLines(
                first: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(color: primary),
                ),
                second: product.code,
                secondColor: secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: _TwoLines(
                first: Text(
                  product.clientName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.row.copyWith(color: primary),
                ),
                second: classInfo.isEmpty ? null : classInfo,
                secondColor: secondary,
              ),
            ),
            SizedBox(
              width: 150,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppBadge(label: productTypeText(strings, product.type)),
              ),
            ),
            SizedBox(
              width: 120,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ProductPrice(price: product.price, style: AppTypography.row),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 110,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ProductAvailabilityBadge(isAvailable: product.isAvailable),
              ),
            ),
            AppIconButton(icon: AppIcons.edit, label: strings.edit, onPressed: onEdit),
            AppIconButton(
              icon: AppIcons.delete,
              label: strings.delete,
              tone: AppTone.danger,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoLines extends StatelessWidget {
  const _TwoLines({required this.first, required this.second, required this.secondColor});

  final Widget first;
  final String? second;
  final Color secondColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        first,
        if (second != null)
          Text(
            second!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.footnote.copyWith(color: secondColor),
          ),
      ],
    );
  }
}
