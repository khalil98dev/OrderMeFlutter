import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_teacher/app/di/injection.dart';
import 'package:medstore_teacher/app/teacher_app.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockLocaleCubit extends MockCubit<Locale?> implements LocaleCubit {}

class _MockSignIn extends Mock implements SignIn {}

class _MockProductRepository extends Mock implements ProductRepository {}

/// One unavailable book whose price the teacher may not see.
class _FakeWatchProducts extends Fake implements WatchProducts {
  @override
  Stream<Result<PagedList<Product>>> call(WatchProductsParams params) => Stream.value(
    Result.ok(
      PagedList(
        items: [
          Product(
            id: 'p1',
            clientId: 'c7',
            name: 'Maths 3AS',
            subject: 'Mathématiques',
            level: '3AS',
            type: ProductType.practiceBook,
            isAvailable: false,
            hasImage: false,
            createdAt: DateTime(2026, 11, 4),
          ),
        ],
        page: 1,
        pageSize: 20,
        totalCount: 1,
      ),
    ),
  );
}

void main() {
  late _MockAuthCubit auth;
  late _MockLocaleCubit locale;

  Future<void> pumpApp(
    WidgetTester tester, {
    required AuthState authState,
    Locale language = const Locale('fr'),
  }) async {
    whenListen(auth, const Stream<AuthState>.empty(), initialState: authState);
    whenListen(locale, const Stream<Locale?>.empty(), initialState: language);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const TeacherApp());
    await tester.pumpAndSettle();
  }

  setUp(() async {
    await sl.reset();
    auth = _MockAuthCubit();
    locale = _MockLocaleCubit();
    sl
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<LocaleCubit>(locale)
      ..registerFactory(() => LoginCubit(_MockSignIn()))
      ..registerSingleton(ProductImages(_MockProductRepository()))
      ..registerFactory(() => ProductsCubit(_FakeWatchProducts()));
  });

  testWidgets('signed out: the login form is shown', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated());

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Commandez vos impressions'), findsOneWidget);
  });

  testWidgets('signed in: the tabs are shown, products first, with their books', (tester) async {
    await pumpApp(
      tester,
      authState: const Authenticated(SessionUser(id: '7', userName: 'prof.amina', role: UserRole.client)),
    );

    expect(find.text('Produits'), findsWidgets);
    expect(find.text('Commandes'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    expect(find.text('Maths 3AS'), findsOneWidget);
    expect(find.text('Mathématiques · 3AS'), findsOneWidget);
    // The teacher may not read prices yet (a secured field): "hidden", never "0 DA".
    expect(find.text('Prix masqué'), findsOneWidget);
    expect(find.text('Indisponible'), findsOneWidget);
  });

  testWidgets('Arabic lays the app out right to left', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated(), language: const Locale('ar'));

    final context = tester.element(find.text('تسجيل الدخول'));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
