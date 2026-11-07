import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'app/admin_app.dart';
import 'app/di/injection.dart';

/// Run with: `flutter run -d windows --dart-define-from-file=env/dev.json`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A desktop app: Apple's Mac text styles (body 13), denser rows and controls.
  AppTypography.useMacScale();
  Bloc.observer = const AppBlocObserver();
  await configureDependencies();
  await sl<LocaleCubit>().load(); // the first frame is already in the saved language
  unawaited(sl<AuthCubit>().restore()); // the splash screen shows until it answers
  runApp(const AdminApp());
}
