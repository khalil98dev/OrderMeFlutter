import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/admin_product_repository.dart';
import '../domain/product_draft.dart';

/// `/api/admin/products`. After every change the cached product lists are dropped, so the next list
/// shows the change; after a cover change the old cover is dropped from the image cache too.
class AdminProductRepositoryImpl implements AdminProductRepository {
  AdminProductRepositoryImpl({
    required ApiClient api,
    required HybridCache cache,
    required ProductImages images,
  }) : _api = api,
       _cache = cache,
       _images = images;

  static const _path = '/api/admin/products';

  final ApiClient _api;
  final HybridCache _cache;
  final ProductImages _images;

  @override
  Future<Result<String>> create(ProductDraft draft) => _afterChange(
    _api.post(
      _path,
      data: {'clientId': draft.teacherId, ..._body(draft)},
      decode: (json) => (json! as Map<String, Object?>)['id']! as String,
    ),
  );

  @override
  Future<Result<void>> update(String productId, ProductDraft draft) => _afterChange(
    _api.put(
      '$_path/$productId',
      data: {..._body(draft), 'isAvailable': draft.isAvailable},
      decode: ApiClient.ignoreBody,
    ),
  );

  @override
  Future<Result<void>> delete(String productId) =>
      _afterChange(_api.delete('$_path/$productId', decode: ApiClient.ignoreBody));

  @override
  Future<Result<void>> setCover(String productId, Uint8List bytes, String fileName) => _afterCoverChange(
    productId,
    _api.put(
      '$_path/$productId/image',
      data: FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)}),
      decode: ApiClient.ignoreBody,
    ),
  );

  @override
  Future<Result<void>> removeCover(String productId) =>
      _afterCoverChange(productId, _api.delete('$_path/$productId/image', decode: ApiClient.ignoreBody));

  /// The JSON both create and update send. Empty optional fields are sent as null, not "".
  static Map<String, Object?> _body(ProductDraft draft) {
    String? optional(String text) => text.trim().isEmpty ? null : text.trim();
    return {
      'name': draft.name.trim(),
      'code': optional(draft.code),
      'description': optional(draft.description),
      'subject': optional(draft.subject),
      'level': optional(draft.level),
      'type': draft.type.apiName,
      'pageCount': draft.pageCount,
      'price': draft.price,
    };
  }

  Future<Result<T>> _afterChange<T>(Future<Result<T>> change) async {
    final result = await change;
    if (result.isOk) await _cache.invalidate('products');
    return result;
  }

  Future<Result<void>> _afterCoverChange(String productId, Future<Result<void>> change) async {
    final result = await _afterChange(change);
    if (result.isOk) _images.changed(productId);
    return result;
  }
}
