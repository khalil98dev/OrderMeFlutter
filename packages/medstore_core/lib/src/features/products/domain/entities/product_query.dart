import 'package:equatable/equatable.dart';

import 'product.dart';

/// What to list: search text, filters and which page.
final class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.type,
    this.isAvailable,
    this.clientId,
    this.page = 1,
    this.pageSize = 20,
  });

  final String search;

  /// Null means every type.
  final ProductType? type;

  /// Null means available and unavailable.
  final bool? isAvailable;

  /// One teacher's products (admin list only; the teacher app always gets its own). Null: everyone's.
  final String? clientId;
  final int page;
  final int pageSize;

  ProductQuery nextPage() => _copy(page: page + 1);

  // Changing what is searched or filtered starts again from the first page.

  ProductQuery withSearch(String value) => _copy(search: value);

  ProductQuery withAvailability(bool? value) => _copy(isAvailable: () => value);

  ProductQuery withType(ProductType? value) => _copy(type: () => value);

  ProductQuery withClient(String? value) => _copy(clientId: () => value);

  ProductQuery _copy({
    String? search,
    ProductType? Function()? type,
    bool? Function()? isAvailable,
    String? Function()? clientId,
    int page = 1,
  }) => ProductQuery(
    search: search ?? this.search,
    type: type == null ? this.type : type(),
    isAvailable: isAvailable == null ? this.isAvailable : isAvailable(),
    clientId: clientId == null ? this.clientId : clientId(),
    page: page,
    pageSize: pageSize,
  );

  /// The query string the API expects; empty filters are left out.
  Map<String, Object?> toQueryParameters() => {
    if (search.isNotEmpty) 'search': search,
    if (type != null) 'type': type!.apiName,
    if (isAvailable != null) 'isAvailable': isAvailable,
    if (clientId != null) 'clientId': clientId,
    'page': page,
    'pageSize': pageSize,
  };

  /// A stable cache key. Starts with "products" so `cache.invalidate('products')` clears every list.
  String get cacheKey =>
      'products?${toQueryParameters().entries.map((e) => '${e.key}=${e.value}').join('&')}';

  @override
  List<Object?> get props => [search, type, isAvailable, clientId, page, pageSize];
}
