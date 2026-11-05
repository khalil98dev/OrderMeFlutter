import 'dart:typed_data';

import 'package:medstore_core/medstore_core.dart';

import 'product_draft.dart';

/// Changing products (`/api/admin/products`, Admin role only). Reading uses the shared `ProductRepository`.
abstract interface class AdminProductRepository {
  /// Returns the new product's id.
  Future<Result<String>> create(ProductDraft draft);

  Future<Result<void>> update(String productId, ProductDraft draft);

  /// A soft delete: the product disappears; past orders keep pointing at it.
  Future<Result<void>> delete(String productId);

  Future<Result<void>> setCover(String productId, Uint8List bytes, String fileName);

  Future<Result<void>> removeCover(String productId);
}
