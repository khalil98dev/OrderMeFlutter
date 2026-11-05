import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

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
  late final AdminRouter _router = AdminRouter(_auth);

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
        // Shared by every screen that shows a product cover.
        RepositoryProvider.value(value: sl<ProductImages>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => CupertinoApp.router(
          onGenerateTitle: (context) =>
              '${AppStrings.of(context).appName} · ${AppStrings.of(context).adminSubtitle}',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.cupertino,
          locale: locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: AppStrings.localizationsDelegates,
          localeResolutionCallback: LocaleCubit.resolve,
          routerConfig: _router.config,
        ),
      ),
    );
  }
}
