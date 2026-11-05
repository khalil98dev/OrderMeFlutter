import 'package:flutter/painting.dart';

import '../../../core/presentation/bytes_image_provider.dart';
import '../../../core/result/result.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/product_repository.dart';

/// Gives screens the cover image of a product, ready for an `Image` (or `AppCoverImage`).
///
/// The image endpoint needs the Bearer token, so it cannot be loaded with `Image.network`; this goes
/// through the API client instead, which also refreshes an expired token.
class ProductImages {
  ProductImages(this._repository);

  final ProductRepository _repository;

  /// After a new cover is uploaded, providers with a new version get a new cache key, so screens
  /// show the new image instead of the cached old one.
  final _versions = <String, int>{};

  /// Null when the product has no cover.
  ImageProvider? cover(Product product) {
    if (!product.hasImage) return null;
    final version = _versions[product.id] ?? 0;
    return BytesImageProvider(
      cacheKey: 'product-cover:${product.id}:$version',
      load: () async => switch (await _repository.getImage(product.id)) {
        Ok(:final value) => value,
        Err() => null,
      },
    );
  }

  /// Call after the cover changed or was removed.
  void changed(String productId) => _versions[productId] = (_versions[productId] ?? 0) + 1;
}
