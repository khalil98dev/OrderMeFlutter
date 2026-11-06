import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../features/cart/cart_cubit.dart';
import '../features/notifications/domain/notification.dart';
import '../features/notifications/presentation/unread_cubit.dart';
import '../features/orders/presentation/orders_page.dart';
import 'di/injection.dart';
import 'router/teacher_router.dart';

/// Root of the teacher mobile app. The router is built once; a language change only rebuilds the app.
///
/// The session's state lives here: the cart, the unread count and the orders list start with a
/// sign-in and are emptied by a sign-out, so the next teacher on the same phone starts clean.
class TeacherApp extends StatefulWidget {
  const TeacherApp({super.key});

  @override
  State<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends State<TeacherApp> {
  final AuthCubit _auth = sl<AuthCubit>();
  final LocaleCubit _locale = sl<LocaleCubit>();
  final CartCubit _cart = sl<CartCubit>();
  final UnreadCubit _unread = sl<UnreadCubit>();
  final MyOrdersCubit _orders = sl<MyOrdersCubit>();
  late final TeacherRouter _router = TeacherRouter(_auth);

  @override
  void initState() {
    super.initState();
    _sessionChanged(_auth.state);
  }

  void _sessionChanged(AuthState state) {
    switch (state) {
      case Authenticated():
        unawaited(_unread.start());
        unawaited(_orders.load());
      case Unauthenticated():
        _cart.clear();
        _unread.stop();
      case AuthUnknown():
        break;
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _auth),
        BlocProvider.value(value: _locale),
        BlocProvider.value(value: _cart),
        BlocProvider.value(value: _unread),
        BlocProvider.value(value: _orders),
        // Shared by every screen that shows a product cover.
        RepositoryProvider.value(value: sl<ProductImages>()),
        RepositoryProvider.value(value: sl<NotificationRepository>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        listener: (_, state) => _sessionChanged(state),
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => CupertinoApp.router(
            onGenerateTitle: (context) => AppStrings.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.cupertino,
            locale: locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: AppStrings.localizationsDelegates,
            localeResolutionCallback: LocaleCubit.resolve,
            routerConfig: _router.config,
          ),
        ),
      ),
    );
  }
}
