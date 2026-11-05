import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';

/// A square icon-only button with a tooltip (desktop) and a screen-reader label.
///
/// ```dart
/// AppIconButton(icon: CupertinoIcons.pencil, label: strings.edit, onPressed: edit)
/// AppIconButton(icon: CupertinoIcons.trash, label: strings.delete, tone: AppTone.danger, filled: true, onPressed: delete)
/// ```
///
/// [label] is required on purpose: an icon alone tells a screen reader nothing.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tone = AppTone.neutral,
    this.filled = false,
    this.size = 32,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final AppTone tone;

  /// Draws the tone's tinted background behind the icon.
  final bool filled;

  /// Width and height of the visible button. The tap area is never smaller than 44 px on touch screens
  /// thanks to `CupertinoButton`'s minimum size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    final iconColor = tone == AppTone.neutral
        ? AppColors.textSecondary.resolveFrom(context)
        : colors.foreground;

    return Tooltip(
      message: label,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        minimumSize: Size.square(size),
        color: filled ? colors.background : null,
        borderRadius: AppRadii.smRadius,
        child: Icon(icon, size: size * 0.55, color: iconColor, semanticLabel: label),
      ),
    );
  }
}
