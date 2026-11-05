import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs Bloc errors always and state changes only in debug builds, so release builds pay nothing.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      developer.log('${bloc.runtimeType}: ${change.nextState.runtimeType}', name: 'bloc');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log('${bloc.runtimeType} failed', name: 'bloc', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
