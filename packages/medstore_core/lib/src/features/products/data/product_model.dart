import '../domain/entities/product.dart';

/// Reads the API's `ProductDto`.
abstract final class ProductModel {
  static Product fromJson(Object? json) {
    final map = json! as Map<String, Object?>;
    return Product(
      id: map['id']! as String,
      clientId: map['clientId']! as String,
      clientName: map['clientName'] as String?,
      name: map['name']! as String,
      code: map['code'] as String?,
      description: map['description'] as String?,
      subject: map['subject'] as String?,
      level: map['level'] as String?,
      type: ProductType.fromApi(map['type'] as String?),
      pageCount: map['pageCount'] as int?,
      price: map['price'] as num?,
      isAvailable: map['isAvailable']! as bool,
      hasImage: map['hasImage']! as bool,
      createdAt: DateTime.parse(map['createdAt']! as String),
    );
  }
}
