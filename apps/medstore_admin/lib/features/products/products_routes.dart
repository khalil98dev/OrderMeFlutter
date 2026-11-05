import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/di/injection.dart';
import '../../app/shell/admin_page.dart';
import '../teachers/domain/teacher_directory.dart';
import 'domain/admin_product_usecases.dart';
import 'presentation/admin_products_page.dart';
import 'presentation/product_form_cubit.dart';
import 'presentation/product_form_page.dart';

/// `/products` (the list), `/products/new` and `/products/:id/edit`.
///
/// Each page gets what it needs here, so the pages themselves never look anything up.
GoRoute productsRoute() => GoRoute(
  path: '/products',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProductsCubit>()..load()),
        RepositoryProvider.value(value: sl<DeleteProduct>()),
        RepositoryProvider.value(value: sl<SearchTeachers>()),
      ],
      child: const AdminProductsPage(),
    ),
  ),
  routes: [
    GoRoute(path: 'new', builder: (_, _) => _form(product: null)),
    GoRoute(
      path: ':id/edit',
      builder: (_, state) => switch (state.extra) {
        final Product product => _form(product: product),
        // Opened without the product in hand (a deep link): fetch it first.
        _ => _LoadThenEdit(productId: state.pathParameters['id']!),
      },
    ),
  ],
);

Widget _form({required Product? product}) => MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => ProductFormCubit(
        createProduct: sl(),
        updateProduct: sl(),
        changeCover: sl(),
        productId: product?.id,
      ),
    ),
    RepositoryProvider.value(value: sl<SearchTeachers>()),
  ],
  child: ProductFormPage(product: product),
);

class _LoadThenEdit extends StatelessWidget {
  const _LoadThenEdit({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit(sl(), productId: productId)..load(),
      child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) => switch (state.product) {
          final product? => _form(product: product),
          null => AdminPage(
            title: AppStrings.of(context).editProduct,
            child: AppLoadView(
              isLoading: state.isLoading,
              hasData: false,
              failure: state.failure,
              onRetry: context.read<ProductDetailCubit>().load,
              loading: const Center(child: CupertinoActivityIndicator()),
              empty: const SizedBox.shrink(),
              builder: (_) => const SizedBox.shrink(),
            ),
          ),
        },
      ),
    );
  }
}
