import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/products/domain/admin_product_repository.dart';
import 'package:medstore_admin/features/products/domain/admin_product_usecases.dart';
import 'package:medstore_admin/features/products/presentation/admin_products_page.dart';
import 'package:medstore_admin/features/teachers/domain/teacher_directory.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsCubit extends MockCubit<ProductsState> implements ProductsCubit {}

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockAdminRepository extends Mock implements AdminProductRepository {}

class _MockTeacherDirectory extends Mock implements TeacherDirectory {}

final _product = Product(
  id: 'p1',
  clientId: 'c1',
  clientName: 'Amina Benali',
  name: 'Maths 3AS',
  code: 'MATH-3AS-01',
  subject: 'Mathématiques',
  level: '3AS',
  type: ProductType.examCollection,
  price: 1250,
  isAvailable: true,
  hasImage: false,
  createdAt: DateTime(2026, 11, 4),
);

void main() {
  late _MockProductsCubit cubit;
  late _MockAdminRepository adminRepository;

  Future<void> pumpPage(WidgetTester tester, ProductsState state) async {
    whenListen(cubit, const Stream<ProductsState>.empty(), initialState: state);
    tester.view.physicalSize = const Size(1360, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertino,
        locale: const Locale('fr'),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: AppStrings.localizationsDelegates,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductsCubit>.value(value: cubit),
            RepositoryProvider.value(value: DeleteProduct(adminRepository)),
            RepositoryProvider.value(value: ProductImages(_MockProductRepository())),
            RepositoryProvider.value(value: SearchTeachers(_MockTeacherDirectory())),
          ],
          child: const AdminProductsPage(),
        ),
      ),
    );
    await tester.pump();
  }

  setUp(() {
    cubit = _MockProductsCubit();
    adminRepository = _MockAdminRepository();
    when(() => cubit.load(refresh: any(named: 'refresh'))).thenAnswer((_) async {});
  });

  testWidgets('shows each product with its teacher, type, price and availability', (tester) async {
    await pumpPage(tester, ProductsState(products: [_product], totalCount: 1));

    expect(find.text('1 produit'), findsOneWidget);
    expect(find.text('Maths 3AS'), findsOneWidget);
    expect(find.text('MATH-3AS-01'), findsOneWidget);
    expect(find.text('Amina Benali'), findsOneWidget);
    expect(find.text("Recueil d'examens"), findsOneWidget);
    expect(find.text('1 250 DA'), findsOneWidget);
    expect(find.text('Disponible'), findsWidgets); // the badge, and the filter segment
  });

  testWidgets('nothing yet: invites to create the first product', (tester) async {
    await pumpPage(tester, const ProductsState());

    expect(find.text('Aucun produit'), findsOneWidget);
    expect(find.text("Créez le premier produit d'un enseignant."), findsOneWidget);
  });

  testWidgets('delete asks first, and nothing is deleted on "Annuler"', (tester) async {
    await pumpPage(tester, ProductsState(products: [_product], totalCount: 1));

    await tester.tap(find.bySemanticsLabel('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer « Maths 3AS » ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    verifyNever(() => adminRepository.delete(any()));
  });

  testWidgets('delete, confirmed: deletes and reloads the list', (tester) async {
    when(() => adminRepository.delete('p1')).thenAnswer((_) async => const Result.ok(null));
    await pumpPage(tester, ProductsState(products: [_product], totalCount: 1));

    await tester.tap(find.bySemanticsLabel('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Supprimer'));
    await tester.pumpAndSettle();

    verify(() => adminRepository.delete('p1')).called(1);
    verify(() => cubit.load(refresh: true)).called(1);
    expect(find.text('Produit supprimé'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // let the toast go
  });
}
