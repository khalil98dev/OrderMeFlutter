import 'package:medstore_core/medstore_core.dart';

import 'admin_product_repository.dart';
import 'product_draft.dart';

/// Creates a product and returns its id.
class CreateProduct implements UseCase<String, ProductDraft> {
  const CreateProduct(this._repository);

  final AdminProductRepository _repository;

  @override
  Future<Result<String>> call(ProductDraft draft) => _repository.create(draft);
}

final class UpdateProductParams {
  const UpdateProductParams(this.productId, this.draft);

  final String productId;
  final ProductDraft draft;
}

class UpdateProduct implements UseCase<void, UpdateProductParams> {
  const UpdateProduct(this._repository);

  final AdminProductRepository _repository;

  @override
  Future<Result<void>> call(UpdateProductParams params) => _repository.update(params.productId, params.draft);
}

final class ChangeCoverParams {
  const ChangeCoverParams(this.productId, this.change);

  final String productId;
  final CoverChange change;
}

/// Uploads, removes, or leaves the cover alone.
class ChangeProductCover implements UseCase<void, ChangeCoverParams> {
  const ChangeProductCover(this._repository);

  final AdminProductRepository _repository;

  @override
  Future<Result<void>> call(ChangeCoverParams params) async => switch (params.change) {
    KeepCover() => const Result.ok(null),
    RemoveCover() => await _repository.removeCover(params.productId),
    NewCover(:final bytes, :final fileName) => await _repository.setCover(params.productId, bytes, fileName),
  };
}

class DeleteProduct implements UseCase<void, String> {
  const DeleteProduct(this._repository);

  final AdminProductRepository _repository;

  @override
  Future<Result<void>> call(String productId) => _repository.delete(productId);
}
