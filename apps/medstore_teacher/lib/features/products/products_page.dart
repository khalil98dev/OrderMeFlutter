import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/choice_chips.dart';
import 'product_card.dart';

/// The teacher's books: a greeting, search, type filters, then a two-column grid that loads more as
/// it scrolls. Pull to refresh.
///
/// Expects a [ProductsCubit] above it (the route provides one).
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  /// Start loading the next page when fewer than this many pixels are left below.
  static const _loadMoreDistance = 600.0;

  /// Room under the grid for the floating cart.
  static const bottomInset = 96.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();
    final type = context.select<ProductsCubit, ProductType?>((cubit) => cubit.state.query.type);

    return CupertinoPageScaffold(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical &&
              notification.metrics.extentAfter < _loadMoreDistance) {
            cubit.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(largeTitle: Text(strings.navProducts), border: null),
            CupertinoSliverRefreshControl(onRefresh: () => cubit.load(refresh: true)),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              sliver: SliverToBoxAdapter(child: _Greeting()),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: AppSearchField(placeholder: strings.searchProducts, onChanged: cubit.search),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: ChoiceChips<ProductType?>(
                  options: {
                    null: strings.filterAll,
                    for (final type in ProductType.values) type: productTypeText(strings, type),
                  },
                  selected: type,
                  onChanged: cubit.showType,
                ),
              ),
            ),
            const _ProductsSliver(),
            const SliverPadding(padding: EdgeInsets.only(bottom: bottomInset)),
          ],
        ),
      ),
    );
  }
}

/// "Hello, prof.amina" and the count of books, as plain text under the large title: it greets, it
/// does not compete with the books below.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final name = context.select<AuthCubit, String>(
      (cubit) => switch (cubit.state) {
        Authenticated(:final user) => user.userName,
        _ => '',
      },
    );
    final count = context.select<ProductsCubit, int>((cubit) => cubit.state.totalCount);
    final secondary = AppColors.textSecondary.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.greeting(name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title3.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${strings.greetingSubtitle} · ${strings.productsCount(count)}',
          style: AppTypography.subheadline.copyWith(color: secondary),
        ),
      ],
    );
  }
}

/// The grid itself, or the loading / error / empty state when there is nothing to show yet.
class _ProductsSliver extends StatelessWidget {
  const _ProductsSliver();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = context.watch<ProductsCubit>().state;

    if (state.products.isEmpty) {
      final searching = state.query.search.isNotEmpty || state.query.type != null;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoadView(
          isLoading: state.isLoading,
          hasData: false,
          failure: state.failure,
          onRetry: context.read<ProductsCubit>().load,
          loading: const _GridSkeleton(),
          builder: (_) => const SizedBox.shrink(),
          empty: AppEmptyState(
            icon: searching ? AppIcons.search : AppIcons.products,
            title: searching ? strings.noResultsTitle : strings.noProductsTitle,
            message: searching ? strings.noResultsMessage : strings.noProductsTeacherMessage,
          ),
        ),
      );
    }

    final products = state.products;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                key: ValueKey(product.id),
                product: product,
                onTap: () => context.go('/products/${product.id}', extra: product),
              );
            },
          ),
          if (state.hasMore)
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: CupertinoActivityIndicator()),
            ),
        ],
      ),
    );
  }
}

const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 240,
  mainAxisSpacing: AppSpacing.sm,
  crossAxisSpacing: AppSpacing.sm,
  childAspectRatio: 0.58,
);

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonPulse(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        gridDelegate: _gridDelegate,
        itemCount: 4,
        itemBuilder: (_, _) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: AppSkeleton(radius: 16)),
            SizedBox(height: AppSpacing.xs),
            AppSkeleton(width: 120),
            SizedBox(height: AppSpacing.xxs),
            AppSkeleton(width: 70, height: 12),
          ],
        ),
      ),
    );
  }
}
