import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show InkWell, Material, MaterialType;

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

enum AppButtonVariant {
  /// The one main action of a screen: garnet fill.
  filled,

  /// Secondary actions: garnet text on a light garnet tint.
  tinted,

  /// Text-only actions inside rows, bars and dialogs.
  plain,

  /// Delete, cancel an order, void a payment: red text on a red tint.
  destructive,
}

enum AppButtonSize {
  /// 44 px high: forms and page actions.
  regular,

  /// 32 px high: inside table rows and cards on desktop.
  small,
}

/// A text button, optionally with an icon.
///
/// ```dart
/// AppButton(label: strings.save, onPressed: save)
/// AppButton(label: strings.delete, variant: AppButtonVariant.destructive, onPressed: delete)
/// AppButton(label: strings.signIn, isLoading: state.isSubmitting, expand: true, onPressed: submit)
/// ```
///
/// A null [onPressed] disables the button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  /// Shows a spinner and ignores taps, keeping the button's size and color.
  final bool isLoading;

  /// Takes the full available width (forms, mobile).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = _ButtonColors.of(context, variant);
    final enabled = onPressed != null && !isLoading;
    final small = size == AppButtonSize.small;
    final radius = small ? AppRadii.xsRadius : AppRadii.smRadius;
    final minSide = small ? (AppTypography.isMac ? 26.0 : 32.0) : AppSpacing.minTouchTarget;

    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        type: MaterialType.button,
        color: (enabled || isLoading ? colors.background : colors.disabledBackground) ?? _transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minSide,
              minHeight: minSide,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: small ? AppSpacing.sm : AppSpacing.md),
              child: Center(
                widthFactor: 1,
                child: _Content(
                  label: label,
                  icon: icon,
                  isLoading: isLoading,
                  expand: expand,
                  // Disabled: the same grey text for every variant, readable on the grey disabled fill.
                  color: enabled || isLoading ? colors.foreground : AppColors.textTertiary.resolveFrom(context),
                  textStyle: small
                      ? AppTypography.footnote.copyWith(fontWeight: FontWeight.w600)
                      : AppTypography.callout.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _transparent = Color(0x00000000);
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.expand,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final leading = isLoading
        ? CupertinoActivityIndicator(color: color, radius: 8)
        : icon != null
        ? Icon(icon, size: textStyle.fontSize! + 1, color: color)
        : null;

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: AppSpacing.xs)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// The colors of each variant, resolved for the current brightness.
final class _ButtonColors {
  const _ButtonColors(this.foreground, this.background, this.disabledBackground);

  factory _ButtonColors.of(BuildContext context, AppButtonVariant variant) {
    final accent = AppColors.accent.resolveFrom(context);
    final neutral = AppColors.neutralTint.resolveFrom(context);
    return switch (variant) {
      AppButtonVariant.filled => _ButtonColors(
        AppColors.onBrand,
        AppColors.accentFill.resolveFrom(context),
        neutral,
      ),
      AppButtonVariant.tinted => _ButtonColors(accent, AppColors.accentTint.resolveFrom(context), neutral),
      AppButtonVariant.plain => _ButtonColors(accent, null, null),
      AppButtonVariant.destructive => _ButtonColors(
        AppColors.destructive.resolveFrom(context),
        AppColors.destructiveTint.resolveFrom(context),
        neutral,
      ),
    };
  }

  final Color foreground;
  final Color? background;
  final Color? disabledBackground;
}
