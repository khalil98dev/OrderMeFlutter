import 'package:equatable/equatable.dart';

/// What kind of book a product is. The API sends the enum's name ("Guide", "PracticeBook", …).
enum ProductType {
  guide('Guide'),
  practiceBook('PracticeBook'),
  examCollection('ExamCollection'),
  other('Other');

  const ProductType(this.apiName);

  final String apiName;

  /// An unknown value (a type added on the server later) reads as [other] instead of failing.
  static ProductType fromApi(String? value) =>
      values.firstWhere((type) => type.apiName == value, orElse: () => other);
}

/// A printed book made for one teacher. Built and priced by the MedStore team; only its owner orders it.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.clientId,
    required this.name,
    required this.type,
    required this.isAvailable,
    required this.hasImage,
    required this.createdAt,
    this.clientName,
    this.code,
    this.description,
    this.subject,
    this.level,
    this.pageCount,
    this.price,
  });

  final String id;

  /// The teacher who owns it.
  final String clientId;
  final String? clientName;

  final String name;

  /// MedStore's own reference, printed on the cover or the shelf ("MATH-3AS-01").
  final String? code;
  final String? description;
  final String? subject;

  /// The class it is for, as teachers write it: "3AS", "4AM", "BAC".
  final String? level;
  final ProductType type;
  final int? pageCount;

  /// Price of one printed copy in DZD. **Null when this user may not see prices** (a secured field).
  final num? price;

  /// False while it cannot be ordered (being reworked, out of paper). It stays visible.
  final bool isAvailable;
  final bool hasImage;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    clientId,
    clientName,
    name,
    code,
    description,
    subject,
    level,
    type,
    pageCount,
    price,
    isAvailable,
    hasImage,
    createdAt,
  ];
}
