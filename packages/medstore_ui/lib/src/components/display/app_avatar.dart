import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_typography.dart';

/// A circle with a person's initials ("Amina Benali" → "AB"; "prof.amina" → "P").
///
/// ```dart
/// AppAvatar(name: teacher.fullName)
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  /// The first letter of the first two words. Works for Arabic names too (Arabic has no case).
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.accentTint.resolveFrom(context), shape: BoxShape.circle),
        child: Text(
          initialsOf(name),
          style: AppTypography.headline.copyWith(
            fontSize: size * 0.4,
            color: AppColors.accent.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}
