import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import 'app/di/injection.dart';
import 'app/teacher_app.dart';

/// Run with: `flutter run --dart-define-from-file=env/dev.json`
/// (`env/dev.json` points the Android emulator at the PC: 10.0.2.2.)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  await configureDependencies();
  await sl<LocaleCubit>().load(); // the first frame is already in the saved language
  unawaited(sl<AuthCubit>().restore()); // the splash screen shows until it answers
  runApp(const TeacherApp());
}
