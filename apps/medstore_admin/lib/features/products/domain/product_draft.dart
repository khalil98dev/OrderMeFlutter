import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// The fields of the product form.
enum ProductField { teacher, name, code, description, subject, level, type, pageCount, price, cover }

/// What is wrong with a field. The form turns it into a sentence in the user's language.
enum FieldProblem {
  required,
  tooLong,
  priceInvalid,
  pageCountInvalid,
  codeTaken,
  teacherUnavailable,
  imageTooLarge,
  imageTypeInvalid,
}

/// What the admin typed in the product form, before it is sent.
///
/// Numbers are kept as the text that was typed, so "12a" can be reported as invalid instead of being
/// silently dropped. The rules match the server's (`Product.Update` and the column lengths).
final class ProductDraft extends Equatable {
  const ProductDraft({
    required this.name,
    this.teacherId,
    this.code = '',
    this.description = '',
    this.subject = '',
    this.level = '',
    this.type = ProductType.guide,
    this.pageCountText = '',
    this.priceText = '',
    this.isAvailable = true,
  });

  /// The form of an existing product.
  factory ProductDraft.of(Product product) => ProductDraft(
    teacherId: product.clientId,
    name: product.name,
    code: product.code ?? '',
    description: product.description ?? '',
    subject: product.subject ?? '',
    level: product.level ?? '',
    type: product.type,
    pageCountText: product.pageCount?.toString() ?? '',
    priceText: product.price?.toString() ?? '',
    isAvailable: product.isAvailable,
  );

  static const maxLengths = {
    ProductField.name: 200,
    ProductField.code: 50,
    ProductField.description: 2000,
    ProductField.subject: 100,
    ProductField.level: 50,
  };

  /// Only needed for a new product: the owner of an existing one never changes.
  final String? teacherId;
  final String name;
  final String code;
  final String description;
  final String subject;
  final String level;
  final ProductType type;
  final String pageCountText;
  final String priceText;
  final bool isAvailable;

  int? get pageCount => int.tryParse(pageCountText.trim());

  /// Accepts "1250", "1 250" and "1250,50".
  num? get price => num.tryParse(priceText.replaceAll(' ', '').replaceAll(',', '.'));

  /// Every problem at once, so the form can mark all wrong fields in one go.
  Map<ProductField, FieldProblem> validate({required bool isNew}) {
    final problems = <ProductField, FieldProblem>{};

    if (isNew && teacherId == null) problems[ProductField.teacher] = FieldProblem.required;
    if (name.trim().isEmpty) problems[ProductField.name] = FieldProblem.required;

    final lengths = {
      ProductField.name: name,
      ProductField.code: code,
      ProductField.description: description,
      ProductField.subject: subject,
      ProductField.level: level,
    };
    for (final MapEntry(key: field, value: text) in lengths.entries) {
      if (text.trim().length > maxLengths[field]!) problems[field] = FieldProblem.tooLong;
    }

    if (priceText.trim().isEmpty) {
      problems[ProductField.price] = FieldProblem.required;
    } else if (price == null || price! < 0) {
      problems[ProductField.price] = FieldProblem.priceInvalid;
    }

    if (pageCountText.trim().isNotEmpty && (pageCount == null || pageCount! <= 0)) {
      problems[ProductField.pageCount] = FieldProblem.pageCountInvalid;
    }

    return problems;
  }

  @override
  List<Object?> get props => [
    teacherId,
    name,
    code,
    description,
    subject,
    level,
    type,
    pageCountText,
    priceText,
    isAvailable,
  ];
}

/// What to do with the cover image when saving.
sealed class CoverChange {
  const CoverChange();
}

final class KeepCover extends CoverChange {
  const KeepCover();
}

final class RemoveCover extends CoverChange {
  const RemoveCover();
}

final class NewCover extends CoverChange {
  const NewCover({required this.bytes, required this.fileName});

  /// The server's limit.
  static const maxBytes = 5 * 1024 * 1024;

  final Uint8List bytes;
  final String fileName;

  bool get isTooLarge => bytes.length > maxBytes;
}

/// Turns a server refusal into the field it is about, using the API's stable error codes.
///
/// Returns an empty map when the failure is not about a field (no connection, not allowed…).
Map<ProductField, FieldProblem> fieldProblemsFrom(Failure failure) {
  if (failure is ConflictFailure) {
    // The only conflict a product save can hit: "Product.CodeExists".
    return const {ProductField.code: FieldProblem.codeTaken};
  }
  if (failure is! ValidationFailure) return const {};

  const byCode = {
    'Product.ClientRequired': (ProductField.teacher, FieldProblem.required),
    'Product.ClientNotFound': (ProductField.teacher, FieldProblem.teacherUnavailable),
    'Product.NameRequired': (ProductField.name, FieldProblem.required),
    'Product.PriceInvalid': (ProductField.price, FieldProblem.priceInvalid),
    'Product.PageCountInvalid': (ProductField.pageCount, FieldProblem.pageCountInvalid),
    'Product.ImageTooLarge': (ProductField.cover, FieldProblem.imageTooLarge),
    'Product.ImageTypeInvalid': (ProductField.cover, FieldProblem.imageTypeInvalid),
  };
  return {
    for (final code in failure.errors.keys)
      if (byCode[code] case (final field, final problem)) field: problem,
  };
}
