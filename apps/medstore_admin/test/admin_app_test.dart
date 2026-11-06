import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/app/admin_app.dart';
import 'package:medstore_admin/app/di/injection.dart';
import 'package:medstore_admin/features/notifications/domain/notification.dart';
import 'package:medstore_admin/features/notifications/presentation/unread_cubit.dart';
import 'package:medstore_admin/features/reports/domain/reports.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockLocaleCubit extends MockCubit<Locale?> implements LocaleCubit {}

class _MockSignIn extends Mock implements SignIn {}

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockReportRepository extends Mock implements ReportRepository {}

/// Two unread on the server; [push] plays the hub sending one.
class _FakeNotifications extends Fake implements NotificationRepository {
  final _arrivals = StreamController<AppNotification>.broadcast();

  void push(AppNotification notification) => _arrivals.add(notification);

  @override
  Future<Result<int>> unreadCount() async => const Result.ok(2);

  @override
  Stream<AppNotification> get arrivals => _arrivals.stream;
}

void main() {
  late _MockAuthCubit auth;
  late _MockLocaleCubit locale;
  late _FakeNotifications notifications;

  Future<void> pumpApp(
    WidgetTester tester, {
    required AuthState authState,
    Locale language = const Locale('fr'),
  }) async {
    whenListen(auth, const Stream<AuthState>.empty(), initialState: authState);
    whenListen(locale, const Stream<Locale?>.empty(), initialState: language);
    tester.view.physicalSize = const Size(1360, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AdminApp());
    await tester.pumpAndSettle();
  }

  setUpAll(() => registerFallbackValue(const ReportPeriod()));

  setUp(() async {
    await sl.reset();
    // The dashboard (the first page once signed in) asks for the summary report.
    final reports = _MockReportRepository();
    when(() => reports.summary(any())).thenAnswer((_) async => const Result.err(NetworkFailure()));
    auth = _MockAuthCubit();
    locale = _MockLocaleCubit();
    notifications = _FakeNotifications();
    sl
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<LocaleCubit>(locale)
      ..registerFactory(() => LoginCubit(_MockSignIn()))
      ..registerSingleton(ProductImages(_MockProductRepository()))
      ..registerSingleton(GetSummaryReport(reports))
      ..registerSingleton<NotificationRepository>(notifications)
      // Lazy: built by the app inside the test's fake-async zone, so live events reach it on pump.
      ..registerLazySingleton(() => UnreadCubit(notifications));
  });

  testWidgets('signed out: the login form is shown', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated());

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text("Espace de l'équipe MedStore"), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('empty fields are refused before any request', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated());

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Ce champ est obligatoire.'), findsNWidgets(2));
  });

  testWidgets('signed in: the sidebar and the dashboard are shown', (tester) async {
    await pumpApp(
      tester,
      authState: const Authenticated(SessionUser(id: '1', userName: 'admin', role: UserRole.admin)),
    );

    expect(find.text('Tableau de bord'), findsWidgets);
    expect(find.text('Créances'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
  });

  testWidgets('a notification pushed live slides in and adds to the sidebar badge', (tester) async {
    await pumpApp(
      tester,
      authState: const Authenticated(SessionUser(id: '1', userName: 'admin', role: UserRole.admin)),
    );
    expect(find.text('2'), findsOneWidget); // the unread count from the server

    notifications.push(
      AppNotification(
        id: 'n1',
        title: 'Nouvelle commande n° 12',
        message: 'prof.amina a passé une commande.',
        type: 'OrderPlaced',
        link: 'orders/o1',
        createdAt: DateTime(2026, 11, 6),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle commande n° 12'), findsOneWidget);
    expect(find.text('Voir la commande'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // It leaves by itself after a few seconds.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle commande n° 12'), findsNothing);
  });

  testWidgets('Arabic lays the app out right to left', (tester) async {
    await pumpApp(tester, authState: const Unauthenticated(), language: const Locale('ar'));

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    final context = tester.element(find.text('تسجيل الدخول'));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
