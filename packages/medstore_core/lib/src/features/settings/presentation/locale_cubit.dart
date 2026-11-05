import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/settings_store.dart';

/// The language the user picked, or null to follow the device.
///
/// The apps speak Arabic and French. A device in any other language gets [fallback].
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._store) : super(null);

  static const supported = [Locale('ar'), Locale('fr')];
  static const fallback = Locale('ar');
  static const _key = 'locale';

  final SettingsStore _store;

  /// Reads the saved choice. `main` awaits it before `runApp`, so the first frame is in the right language.
  Future<void> load() async {
    final code = await _store.read(_key);
    emit(code == null ? null : Locale(code));
  }

  Future<void> choose(Locale? locale) async {
    emit(locale);
    await _store.write(_key, locale?.languageCode);
  }

  /// For `CupertinoApp.localeResolutionCallback`: the device language if supported, else [fallback].
  static Locale resolve(Locale? device, Iterable<Locale> supportedLocales) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == device?.languageCode) return locale;
    }
    return fallback;
  }
}
