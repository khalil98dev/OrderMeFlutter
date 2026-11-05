import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'gallery_page.dart';

/// A live catalog of every `medstore_ui` component.
///
/// Run with `flutter run -d chrome` from this folder. Switch language and brightness from the top bar.
void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  var _locale = const Locale('fr');
  var _brightness = Brightness.light;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'MedStore UI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertino.copyWith(brightness: _brightness),
      locale: _locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: AppStrings.localizationsDelegates,
      home: GalleryPage(
        brightness: _brightness,
        onBrightnessChanged: (value) => setState(() => _brightness = value),
        onLocaleChanged: (value) => setState(() => _locale = value),
      ),
    );
  }
}
