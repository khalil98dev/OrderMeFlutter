import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/admin_product_usecases.dart';
import '../domain/product_draft.dart';

enum ProductFormStatus { editing, saving, saved, failed }

final class ProductFormState extends Equatable {
  const ProductFormState({
    this.status = ProductFormStatus.editing,
    this.problems = const {},
    this.failure,
    this.coverFailed = false,
  });

  final ProductFormStatus status;

  /// Fields to mark, from the form's own checks or from the server's answer.
  final Map<ProductField, FieldProblem> problems;

  /// Why saving failed, when it is not about one field (no connection, not allowed…).
  final Failure? failure;

  /// The product was saved but its cover was not: saving again retries the cover.
  final bool coverFailed;

  bool get isSaving => status == ProductFormStatus.saving;

  @override
  List<Object?> get props => [status, problems, failure, coverFailed];
}

/// Saves the product form: checks it, creates or updates the product, then applies the cover change.
///
/// If the product is created but its cover upload fails, the cubit remembers the new product, so the
/// next "Save" updates it instead of creating a second one.
class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required ChangeProductCover changeCover,
    this.productId,
  }) : _createProduct = createProduct,
       _updateProduct = updateProduct,
       _changeCover = changeCover,
       super(const ProductFormState());

  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final ChangeProductCover _changeCover;

  /// Null for a new product.
  final String? productId;

  String? _createdId;

  bool get isNew => productId == null;

  Future<void> save(ProductDraft draft, CoverChange cover) async {
    if (state.isSaving) return;

    final problems = draft.validate(isNew: isNew);
    if (cover is NewCover && cover.isTooLarge) problems[ProductField.cover] = FieldProblem.imageTooLarge;
    if (problems.isNotEmpty) {
      emit(ProductFormState(status: ProductFormStatus.failed, problems: problems));
      return;
    }

    emit(const ProductFormState(status: ProductFormStatus.saving));

    final savedId = await _saveDetails(draft);
    if (savedId == null) return; // _saveDetails already reported the failure

    final coverResult = await _changeCover(ChangeCoverParams(savedId, cover));
    if (coverResult case Err(:final failure)) {
      emit(_failed(failure, coverFailed: true));
      return;
    }

    emit(const ProductFormState(status: ProductFormStatus.saved));
  }

  /// Creates or updates the product; returns its id, or null after emitting the failure.
  Future<String?> _saveDetails(ProductDraft draft) async {
    final existingId = productId ?? _createdId;

    if (existingId == null) {
      switch (await _createProduct(draft)) {
        case Ok(:final value):
          _createdId = value;
          return value;
        case Err(:final failure):
          emit(_failed(failure));
          return null;
      }
    }

    switch (await _updateProduct(UpdateProductParams(existingId, draft))) {
      case Ok():
        return existingId;
      case Err(:final failure):
        emit(_failed(failure));
        return null;
    }
  }

  static ProductFormState _failed(Failure failure, {bool coverFailed = false}) => ProductFormState(
    status: ProductFormStatus.failed,
    problems: fieldProblemsFrom(failure),
    failure: failure,
    coverFailed: coverFailed,
  );
}
