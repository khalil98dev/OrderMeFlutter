import 'package:flutter/widgets.dart';

/// The MedStore gem logo.
///
/// Decoded at the size it is shown (`cacheWidth`), not at the file's 512 px, so a 36 px sidebar logo
/// costs a 36 px bitmap in memory.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.asset(
      'assets/brand/logo.png',
      package: 'medstore_ui',
      width: size,
      height: size,
      cacheWidth: pixels,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'MedStore',
    );
  }
}
