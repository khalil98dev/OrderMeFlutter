import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../features/notifications/domain/notification.dart';
import '../features/notifications/presentation/unread_cubit.dart';
import '../features/orders/presentation/order_changes.dart';
import 'di/injection.dart';
import 'router/admin_router.dart';

/// Root of the admin desktop app.
///
/// The router is built once and kept: rebuilding [CupertinoApp] on a language change does not rebuild
/// the router or lose the current page.
class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final AuthCubit _auth = sl<AuthCubit>();
  final LocaleCubit _locale = sl<LocaleCubit>();
  final UnreadCubit _unread = sl<UnreadCubit>();
  late final AdminRouter _router = AdminRouter(_auth);

  @override
  void initState() {
    super.initState();
    _sessionChanged(_auth.state);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  /// The unread count belongs to the signed-in member: counted at sign-in, cleared at sign-out.
  void _sessionChanged(AuthState state) {
    switch (state) {
      case Authenticated():
        unawaited(_unread.start());
      case Unauthenticated():
        _unread.stop();
      case AuthUnknown():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _auth),
        BlocProvider.value(value: _locale),
        BlocProvider.value(value: _unread),
        // Shared by every screen that shows a product cover.
        RepositoryProvider.value(value: sl<ProductImages>()),
        // Live notifications: the shell announces them, lists reload on them.
        RepositoryProvider.value(value: sl<NotificationRepository>()),
        // An order changed on its page: the orders list reloads.
        RepositoryProvider.value(value: sl<OrderChanges>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        listener: (_, state) => _sessionChanged(state),
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => CupertinoApp.router(
            onGenerateTitle: (context) =>
                '${AppStrings.of(context).appName} · ${AppStrings.of(context).adminSubtitle}',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.cupertino,
            locale: locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: appLocalizationsDelegates,
            localeResolutionCallback: LocaleCubit.resolve,
            routerConfig: _router.config,
          ),
        ),
      ),
    );
  }
}
