import 'package:flutter/cupertino.dart';

import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// An inline message in a tinted box: a failed sign-in, an offline notice, a hint above a form.
///
/// ```dart
/// AppMessage(text: failureText(strings, failure))                       // danger by default
/// AppMessage(text: strings.offlineNotice, tone: AppTone.warning)
/// ```
///
/// Screen readers announce it when it appears.
class AppMessage extends StatelessWidget {
  const AppMessage({super.key, required this.text, this.tone = AppTone.danger, this.icon});

  final String text;
  final AppTone tone;

  /// Defaults to an icon that matches the tone.
  final IconData? icon;

  static IconData _defaultIcon(AppTone tone) => switch (tone) {
    AppTone.danger => CupertinoIcons.exclamationmark_circle,
    AppTone.warning => CupertinoIcons.exclamationmark_triangle,
    AppTone.success => CupertinoIcons.check_mark_circled,
    AppTone.neutral || AppTone.brand || AppTone.info => CupertinoIcons.info_circle,
  };

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.background, borderRadius: AppRadii.smRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon ?? _defaultIcon(tone), size: 18, color: colors.foreground),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(text, style: AppTypography.subheadline.copyWith(color: colors.foreground)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
