import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show InkWell, Material, MaterialType, Tooltip;

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';

/// A square icon-only button with a tooltip (desktop) and a screen-reader label.
///
/// ```dart
/// AppIconButton(icon: AppIcons.edit, label: strings.edit, onPressed: edit)
/// AppIconButton(icon: AppIcons.delete, label: strings.delete, tone: AppTone.danger, filled: true, onPressed: delete)
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

  /// Width and height of the button, which is also its tap area.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    final iconColor = tone == AppTone.neutral
        ? AppColors.textSecondary.resolveFrom(context)
        : colors.foreground;

    return Tooltip(
      message: label,
      child: Material(
        type: MaterialType.button,
        color: filled ? colors.background : const Color(0x00000000),
        borderRadius: AppRadii.smRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.smRadius,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: Icon(icon, size: size * 0.55, color: iconColor, semanticLabel: label),
            ),
          ),
        ),
      ),
    );
  }
}
