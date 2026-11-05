import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'product_card.dart';

/// The teacher's books: large title, pull to refresh, search, and more rows as they scroll.
///
/// Expects a [ProductsCubit] above it (the route provides one).
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  /// Start loading the next page when fewer than this many pixels are left below.
  static const _loadMoreDistance = 600.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();

    return CupertinoPageScaffold(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < _loadMoreDistance) cubit.loadMore();
          return false;
        },
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(largeTitle: Text(strings.navProducts), border: null),
            CupertinoSliverRefreshControl(onRefresh: () => cubit.load(refresh: true)),
            SliverPadding(
              padding: AppSpacing.screenMobile,
              sliver: SliverToBoxAdapter(
                child: AppSearchField(placeholder: strings.searchProducts, onChanged: cubit.search),
              ),
            ),
            const _ProductsSliver(),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

/// The list itself, or the loading / error / empty state when there is nothing to show yet.
class _ProductsSliver extends StatelessWidget {
  const _ProductsSliver();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = context.watch<ProductsCubit>().state;

    if (state.products.isEmpty) {
      final searching = state.query.search.isNotEmpty;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoadView(
          isLoading: state.isLoading,
          hasData: false,
          failure: state.failure,
          onRetry: context.read<ProductsCubit>().load,
          builder: (_) => const SizedBox.shrink(),
          empty: AppEmptyState(
            icon: searching ? CupertinoIcons.search : CupertinoIcons.book,
            title: searching ? strings.noResultsTitle : strings.noProductsTitle,
            message: searching ? strings.noResultsMessage : strings.noProductsTeacherMessage,
          ),
        ),
      );
    }

    final products = state.products;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.separated(
        // One extra row at the end shows a spinner while the next page loads.
        itemCount: products.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Padding(padding: EdgeInsets.all(AppSpacing.md), child: CupertinoActivityIndicator());
          }
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => context.go('/products/${product.id}', extra: product),
          );
        },
      ),
    );
  }
}
