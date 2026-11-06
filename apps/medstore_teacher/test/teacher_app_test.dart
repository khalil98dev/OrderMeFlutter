import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_teacher/app/di/injection.dart';
import 'package:medstore_teacher/app/teacher_app.dart';
import 'package:medstore_teacher/features/cart/cart_cubit.dart';
import 'package:medstore_teacher/features/notifications/domain/notification.dart';
import 'package:medstore_teacher/features/notifications/presentation/unread_cubit.dart';
import 'package:medstore_teacher/features/orders/domain/my_orders.dart';
import 'package:medstore_teacher/features/orders/presentation/orders_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockLocaleCubit extends MockCubit<Locale?> implements LocaleCubit {}

class _MockSignIn extends Mock implements SignIn {}

class _MockProductRepository extends Mock implements ProductRepository {}

/// An unavailable book whose price the teacher may not see, and an available one at 450 DA.
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
          Product(
            id: 'p2',
            clientId: 'c7',
            name: 'Physique BAC',
            subject: 'Physique',
            level: 'BAC',
            type: ProductType.guide,
            price: 450,
            isAvailable: true,
            hasImage: false,
            createdAt: DateTime(2026, 11, 5),
          ),
        ],
        page: 1,
        pageSize: 20,
        totalCount: 2,
      ),
    ),
  );
}

/// No notifications, and nothing pushed live.
class _FakeNotifications extends Fake implements NotificationRepository {
  @override
  Future<Result<PagedList<TeacherNotification>>> list(NotificationFilter filter, {int page = 1}) async =>
      const Result.ok(PagedList.empty());

  @override
  Future<Result<int>> unreadCount() async => const Result.ok(3);

  @override
  Stream<TeacherNotification> get arrivals => const Stream.empty();
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
    final notifications = _FakeNotifications();
    sl
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<LocaleCubit>(locale)
      ..registerFactory(() => LoginCubit(_MockSignIn()))
      ..registerSingleton(ProductImages(_MockProductRepository()))
      ..registerFactory(() => ProductsCubit(_FakeWatchProducts()))
      ..registerSingleton(CartCubit())
      ..registerSingleton<NotificationRepository>(notifications)
      ..registerSingleton(UnreadCubit(notifications))
      ..registerSingleton(
        MyOrdersCubit(
          (_, _) async => const Result.ok(PagedList<OrderSummary>.empty()),
          filter: const MyOrdersFilter(),
        ),
      );
  });

  const signedIn = Authenticated(SessionUser(id: '7', userName: 'prof.amina', role: UserRole.client));

  testWidgets('signed out: the login form is shown', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated());

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Commandez vos impressions'), findsOneWidget);
  });

  testWidgets('signed in: the tabs are shown, products first, with their books', (tester) async {
    await pumpApp(tester, authState: signedIn);

    expect(find.text('Produits'), findsWidgets);
    expect(find.text('Commandes'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Bonjour, prof.amina'), findsOneWidget);

    expect(find.text('Maths 3AS'), findsOneWidget);
    expect(find.text('Mathématiques · 3AS'), findsOneWidget);
    // The teacher may not read prices yet (a secured field): "hidden", never "0 DA".
    expect(find.text('Prix masqué'), findsOneWidget);
    expect(find.text('Indisponible'), findsOneWidget);
    // The unread count from the server is on the notifications tab.
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('adding a book fills the floating cart, and only an available book can be added', (
    tester,
  ) async {
    await pumpApp(tester, authState: signedIn);

    // Only "Physique BAC" is available, so there is exactly one add button.
    final add = find.byTooltip('Ajouter au panier');
    expect(add, findsOneWidget);
    expect(find.text('Voir le panier'), findsNothing);

    await tester.tap(add);
    await tester.pumpAndSettle(); // the flight lands and the cart bounces

    expect(sl<CartCubit>().state.copies, 1);
    expect(find.text('Voir le panier'), findsOneWidget);
    expect(find.text('1 exemplaire'), findsOneWidget);
    expect(find.text('1 dans le panier'), findsOneWidget);

    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('2 exemplaires'), findsOneWidget);
  });

  testWidgets('Arabic lays the app out right to left', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated(), language: const Locale('ar'));

    final context = tester.element(find.text('تسجيل الدخول'));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
