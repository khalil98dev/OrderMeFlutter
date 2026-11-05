import '../../../../core/pagination/paged_list.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../repositories/product_repository.dart';

final class WatchProductsParams {
  const WatchProductsParams(this.query, {this.refresh = false});

  final ProductQuery query;
  final bool refresh;
}

/// A page of products: cached first, then fresh.
class WatchProducts {
  const WatchProducts(this._repository);

  final ProductRepository _repository;

  Stream<Result<PagedList<Product>>> call(WatchProductsParams params) =>
      _repository.watchProducts(params.query, refresh: params.refresh);
}

/// One product, always fresh (a detail screen should show the current price and availability).
class GetProduct implements UseCase<Product, String> {
  const GetProduct(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(String productId) => _repository.getProduct(productId);
}
