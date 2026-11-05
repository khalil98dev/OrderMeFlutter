import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/admin_product_usecases.dart';
import 'product_row.dart';

/// Every product: search, filter by availability, create, edit, delete.
///
/// Expects a [ProductsCubit] and the [DeleteProduct] use case above it (the route provides both).
class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();
    final totalCount = context.select<ProductsCubit, int>((cubit) => cubit.state.totalCount);
    final availability = context.select<ProductsCubit, bool?>((cubit) => cubit.state.query.isAvailable);

    return AdminPage(
      title: strings.navProducts,
      // When there are none, the empty state already says so.
      subtitle: totalCount > 0 ? strings.productsCount(totalCount) : null,
      actions: [
        AppButton(
          label: strings.newProduct,
          icon: CupertinoIcons.add,
          onPressed: () => _openForm(context, path: '/products/new'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppSearchField(placeholder: strings.searchProducts, onChanged: cubit.search),
              ),
              const SizedBox(width: AppSpacing.md),
              const SizedBox(width: 260, child: _TeacherFilter()),
              const SizedBox(width: AppSpacing.md),
              AppSegmentedControl<_Availability>(
                segments: {
                  _Availability.all: strings.filterAll,
                  _Availability.available: strings.productAvailable,
                  _Availability.unavailable: strings.productUnavailable,
                },
                selected: _Availability.of(availability),
                onChanged: (value) => cubit.showAvailability(value.isAvailable),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _ProductList(
              onEdit: (product) => _openForm(context, path: '/products/${product.id}/edit', product: product),
              onDelete: (product) => _confirmDelete(context, product),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the form; when it comes back saved, shows a confirmation and reloads the list.
  static Future<void> _openForm(BuildContext context, {required String path, Product? product}) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();
    final saved = await context.push<bool>(path, extra: product);
    if (saved != true || !context.mounted) return;
    showAppToast(context, strings.productSaved, tone: AppTone.success);
    await cubit.load(refresh: true);
  }

  static Future<void> _confirmDelete(BuildContext context, Product product) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();
    final deleteProduct = context.read<DeleteProduct>();

    final confirmed = await showAppConfirmDialog(
      context,
      title: strings.deleteProductTitle(product.name),
      message: strings.deleteProductMessage,
      confirmLabel: strings.delete,
      destructive: true,
    );
    if (!confirmed) return;

    final result = await deleteProduct(product.id);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.productDeleted, tone: AppTone.success);
        await cubit.load(refresh: true);
      case Err(:final failure):
        showAppToast(context, failureText(strings, failure), tone: AppTone.danger);
    }
  }
}

/// Narrows the list to one teacher's products.
class _TeacherFilter extends StatefulWidget {
  const _TeacherFilter();

  @override
  State<_TeacherFilter> createState() => _TeacherFilterState();
}

class _TeacherFilterState extends State<_TeacherFilter> {
  String? _name;

  @override
  Widget build(BuildContext context) {
    return TeacherFilterField(
      search: context.read<SearchTeachers>(),
      teacherName: _name,
      onChanged: (teacher) {
        setState(() => _name = teacher?.$2);
        context.read<ProductsCubit>().showTeacher(teacher?.$1);
      },
    );
  }
}

/// The three choices of the availability filter.
enum _Availability {
  all(null),
  available(true),
  unavailable(false);

  const _Availability(this.isAvailable);

  final bool? isAvailable;

  static _Availability of(bool? isAvailable) =>
      values.firstWhere((value) => value.isAvailable == isAvailable);
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.onEdit, required this.onDelete});

  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductsCubit>();
    final state = context.watch<ProductsCubit>().state;
    final filtered = state.query.search.isNotEmpty || state.query.isAvailable != null;

    return AppLoadView(
      isLoading: state.isLoading,
      hasData: state.products.isNotEmpty,
      failure: state.failure,
      onRetry: cubit.load,
      empty: AppEmptyState(
        icon: filtered ? CupertinoIcons.search : CupertinoIcons.book,
        title: filtered ? strings.noResultsTitle : strings.noProductsTitle,
        message: filtered ? strings.noResultsMessage : strings.noProductsAdminMessage,
      ),
      builder: (context) => AppCard(
        padding: EdgeInsets.zero,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 400) cubit.loadMore();
            return false;
          },
          child: ListView.separated(
            itemCount: state.products.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const _RowSeparator(),
            itemBuilder: (context, index) {
              if (index == state.products.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CupertinoActivityIndicator(),
                );
              }
              final product = state.products[index];
              return ProductRow(
                product: product,
                onEdit: () => onEdit(product),
                onDelete: () => onDelete(product),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RowSeparator extends StatelessWidget {
  const _RowSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 72),
      child: SizedBox(height: 0.5, child: ColoredBox(color: AppColors.separator.resolveFrom(context))),
    );
  }
}
