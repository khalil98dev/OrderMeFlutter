import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/products/domain/admin_product_repository.dart';
import 'package:medstore_admin/features/products/domain/admin_product_usecases.dart';
import 'package:medstore_admin/features/products/domain/product_draft.dart';
import 'package:medstore_admin/features/products/presentation/product_form_cubit.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AdminProductRepository {}

const _valid = ProductDraft(teacherId: 't1', name: 'Maths 3AS', priceText: '1200');

void main() {
  group('ProductDraft.validate', () {
    test('a complete draft has no problems', () {
      expect(_valid.validate(isNew: true), isEmpty);
    });

    test('reports every problem at once', () {
      const draft = ProductDraft(name: ' ', priceText: '-5', pageCountText: '0');
      expect(draft.validate(isNew: true), {
        ProductField.teacher: FieldProblem.required,
        ProductField.name: FieldProblem.required,
        ProductField.price: FieldProblem.priceInvalid,
        ProductField.pageCount: FieldProblem.pageCountInvalid,
      });
    });

    test('an existing product needs no teacher; "1 250,50" is a valid price', () {
      const draft = ProductDraft(name: 'Physique', priceText: '1 250,50');
      expect(draft.validate(isNew: false), isEmpty);
      expect(draft.price, 1250.5);
    });

    test('text longer than the server column is too long', () {
      final draft = ProductDraft(name: 'x' * 201, priceText: '10');
      expect(draft.validate(isNew: false)[ProductField.name], FieldProblem.tooLong);
    });
  });

  group('fieldProblemsFrom', () {
    test('maps the API error codes to their fields', () {
      const failure = ValidationFailure({
        'Product.NameRequired': ['Product name is required.'],
        'Product.ImageTypeInvalid': ['…'],
      });
      expect(fieldProblemsFrom(failure), {
        ProductField.name: FieldProblem.required,
        ProductField.cover: FieldProblem.imageTypeInvalid,
      });
    });

    test('a conflict is the product code already in use', () {
      expect(fieldProblemsFrom(const ConflictFailure()), {ProductField.code: FieldProblem.codeTaken});
    });

    test('a failure unrelated to fields marks nothing', () {
      expect(fieldProblemsFrom(const NetworkFailure()), isEmpty);
    });
  });

  group('ProductFormCubit', () {
    late _MockRepository repository;

    ProductFormCubit cubit({String? productId}) => ProductFormCubit(
      createProduct: CreateProduct(repository),
      updateProduct: UpdateProduct(repository),
      changeCover: ChangeProductCover(repository),
      productId: productId,
    );

    setUp(() {
      repository = _MockRepository();
      registerFallbackValue(_valid);
      registerFallbackValue(Uint8List(0));
    });

    test('an invalid form is not sent', () async {
      final form = cubit();
      await form.save(const ProductDraft(name: ''), const KeepCover());

      expect(form.state.status, ProductFormStatus.failed);
      expect(form.state.problems[ProductField.name], FieldProblem.required);
      verifyNever(() => repository.create(any()));
    });

    test('a cover over 5 MB is refused before uploading', () async {
      final form = cubit();
      await form.save(_valid, NewCover(bytes: Uint8List(NewCover.maxBytes + 1), fileName: 'big.jpg'));

      expect(form.state.problems[ProductField.cover], FieldProblem.imageTooLarge);
      verifyNever(() => repository.create(any()));
    });

    test('created but cover failed: saving again updates the same product, never a second one', () async {
      when(() => repository.create(any())).thenAnswer((_) async => const Result.ok('p1'));
      when(() => repository.update(any(), any())).thenAnswer((_) async => const Result.ok(null));
      var uploads = 0;
      when(
        () => repository.setCover(any(), any(), any()),
      ).thenAnswer((_) async => uploads++ == 0 ? const Result.err(NetworkFailure()) : const Result.ok(null));
      final cover = NewCover(bytes: Uint8List(10), fileName: 'cover.jpg');
      final form = cubit();

      await form.save(_valid, cover);
      expect(form.state.coverFailed, isTrue);

      await form.save(_valid, cover);
      expect(form.state.status, ProductFormStatus.saved);
      verify(() => repository.create(any())).called(1);
      verify(() => repository.update('p1', any())).called(1);
    });

    test('a code already in use marks the code field', () async {
      when(
        () => repository.update(any(), any()),
      ).thenAnswer((_) async => const Result.err(ConflictFailure()));
      final form = cubit(productId: 'p9');

      await form.save(_valid, const KeepCover());

      expect(form.state.problems, {ProductField.code: FieldProblem.codeTaken});
    });
  });
}
