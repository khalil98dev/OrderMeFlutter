import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/cache/hybrid_cache.dart';
import '../../../core/network/api_client.dart';
import '../../../core/pagination/paged_list.dart';
import '../../../core/result/result.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_query.dart';
import '../domain/repositories/product_repository.dart';
import 'product_model.dart';

/// Products from `GET /api/products`, with lists kept in the hybrid cache for 5 minutes.
///
/// The admin app lists from [listPath] `/api/admin/products` instead (every teacher's, `clientId` filter);
/// one product and its cover are read from `/api/products` by both apps.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ApiClient api, required HybridCache cache, this.listPath = defaultListPath})
    : _api = api,
      _cache = cache;

  static const defaultListPath = '/api/products';

  final String listPath;

  static const listMaxAge = Duration(minutes: 5);

  final ApiClient _api;
  final HybridCache _cache;

  @override
  Stream<Result<PagedList<Product>>> watchProducts(ProductQuery query, {bool refresh = false}) {
    return _cache.fetch(
      key: query.cacheKey,
      maxAge: listMaxAge,
      forceRefresh: refresh,
      fetch: () => _api.get(listPath, query: query.toQueryParameters(), decode: ApiClient.rawJson),
      decode: (json) => PagedList.fromJson(json, ProductModel.fromJson),
    );
  }

  @override
  Future<Result<Product>> getProduct(String id) =>
      _api.get('/api/products/$id', decode: ProductModel.fromJson);

  @override
  Future<Result<Uint8List>> getImage(String productId) => _api.get(
    '/api/products/$productId/image',
    options: Options(responseType: ResponseType.bytes),
    decode: (bytes) => Uint8List.fromList(bytes! as List<int>),
  );
}
