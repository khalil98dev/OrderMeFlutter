import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../core/result/result.dart';
import '../domain/entities/product.dart';
import '../domain/usecases/product_usecases.dart';

final class ProductDetailState extends Equatable {
  const ProductDetailState({this.product, this.isLoading = false, this.failure});

  final Product? product;
  final bool isLoading;
  final Failure? failure;

  @override
  List<Object?> get props => [product, isLoading, failure];
}

/// One product. Opened from a list, it shows the product it was given at once, then the fresh one.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getProduct, {required this.productId, Product? initial})
    : super(ProductDetailState(product: initial));

  final GetProduct _getProduct;
  final String productId;

  Future<void> load() async {
    emit(ProductDetailState(product: state.product, isLoading: true));
    final result = await _getProduct(productId);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => ProductDetailState(product: value),
      Err(:final failure) => ProductDetailState(product: state.product, failure: failure),
    });
  }
}
