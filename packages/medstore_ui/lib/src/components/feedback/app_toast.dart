import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// Shows a short message at the bottom of the screen for a few seconds: "Order saved", "Copied".
///
/// ```dart
/// showAppToast(context, strings.orderSaved, tone: AppTone.success);
/// ```
///
/// Only one toast shows at a time; a new one replaces the current one. Use it for confirmations, not
/// for errors the user must act on (those belong in an `AppMessage` next to what failed).
void showAppToast(
  BuildContext context,
  String message, {
  AppTone tone = AppTone.neutral,
  Duration duration = const Duration(seconds: 3),
}) {
  _ToastController.instance.show(Overlay.of(context, rootOverlay: true), message, tone, duration);
}

class _ToastController {
  _ToastController._();

  static final instance = _ToastController._();

  OverlayEntry? _entry;
  Timer? _timer;

  void show(OverlayState overlay, String message, AppTone tone, Duration duration) {
    _hide();
    final entry = OverlayEntry(
      builder: (_) => _Toast(message: message, tone: tone),
    );
    overlay.insert(entry);
    _entry = entry;
    _timer = Timer(duration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message, required this.tone});

  final String message;
  final AppTone tone;

  static IconData? _iconFor(AppTone tone) => switch (tone) {
    AppTone.success => AppIcons.success,
    AppTone.danger => AppIcons.error,
    AppTone.warning => AppIcons.warning,
    AppTone.info || AppTone.accent => AppIcons.info,
    AppTone.neutral => null,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(tone);
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppDurations.of(context, AppDurations.selection),
            curve: AppDurations.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Dark pill in light mode and light pill in dark mode: the inverse of the page.
                color: AppColors.textPrimary.resolveFrom(context).withValues(alpha: 0.92),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: tone.resolve(context).foreground),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        message,
                        style: AppTypography.row.copyWith(color: AppColors.canvas.resolveFrom(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
