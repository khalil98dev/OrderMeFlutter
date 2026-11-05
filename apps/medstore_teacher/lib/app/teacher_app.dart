import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'di/injection.dart';
import 'router/teacher_router.dart';

/// Root of the teacher mobile app. The router is built once; a language change only rebuilds the app.
class TeacherApp extends StatefulWidget {
  const TeacherApp({super.key});

  @override
  State<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends State<TeacherApp> {
  final AuthCubit _auth = sl<AuthCubit>();
  final LocaleCubit _locale = sl<LocaleCubit>();
  late final TeacherRouter _router = TeacherRouter(_auth);

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
    );
  }
}
