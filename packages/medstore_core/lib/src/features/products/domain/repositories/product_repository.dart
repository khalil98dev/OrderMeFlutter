import 'dart:typed_data';

import '../../../../core/pagination/paged_list.dart';
import '../../../../core/result/result.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';

/// Reading products. A teacher gets only their own; the team gets every product (the API decides).
abstract interface class ProductRepository {
  /// Cached answer first (if any), then the fresh one. [refresh] skips the cache (pull to refresh).
  Stream<Result<PagedList<Product>>> watchProducts(ProductQuery query, {bool refresh = false});

  Future<Result<Product>> getProduct(String id);

  /// The cover image's bytes (JPEG, PNG or WebP).
  Future<Result<Uint8List>> getImage(String productId);
}
