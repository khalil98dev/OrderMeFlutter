import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// One book: the cover, its price and availability, then its details.
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

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final primary = AppColors.textPrimary.resolveFrom(context);

    return ListView(
      padding: AppSpacing.screenMobile.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xl),
      children: [
        Center(
          child: AppCoverImage(
            image: context.read<ProductImages>().cover(product),
            width: 200,
            semanticLabel: product.name,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          product.name,
          textAlign: TextAlign.center,
          style: AppTypography.title2.copyWith(color: primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          children: [
            AppBadge(label: productTypeText(strings, product.type)),
            ProductAvailabilityBadge(isAvailable: product.isAvailable),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: ProductPrice(price: product.price, style: AppTypography.title3, perCopy: true),
        ),
        if (!product.isAvailable) ...[
          const SizedBox(height: AppSpacing.md),
          AppMessage(text: strings.productUnavailableNotice, tone: AppTone.warning),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppSection(
          header: strings.productDetails,
          children: [
            if (product.code case final code?) _DetailRow(label: strings.fieldCode, value: code),
            if (product.subject case final subject?) _DetailRow(label: strings.fieldSubject, value: subject),
            if (product.level case final level?) _DetailRow(label: strings.fieldLevel, value: level),
            if (product.pageCount case final pages?)
              _DetailRow(label: strings.fieldPageCount, value: strings.pageCount(pages)),
            _DetailRow(label: strings.fieldType, value: productTypeText(strings, product.type)),
          ],
        ),
        if (product.description case final description?) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Text(description, style: AppTypography.body.copyWith(color: primary)),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: label,
      trailing: Text(
        value,
        style: AppTypography.body.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
      ),
    );
  }
}
