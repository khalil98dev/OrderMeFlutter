import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// One row of [showAppSelectPopup].
final class AppSelectOption<T> {
  const AppSelectOption(this.value, this.label);

  final T value;
  final String label;
}

/// The answer of [showAppSelectPopup]: a picked [value], which may itself be null (an "All" row).
/// The popup returns no answer at all when it was closed without picking.
final class AppSelectResult<T> {
  const AppSelectResult(this.value);

  final T value;
}

/// A list of choices in a frosted panel over the blurred screen, like a macOS / iOS popup menu.
///
/// The page behind blurs and dims as the panel scales and fades in; the rows follow one after the
/// other. Tapping outside, the Cancel row or Escape closes it with no answer. With "reduce motion" the
/// panel only fades.
///
/// ```dart
/// final picked = await showAppSelectPopup(
///   context,
///   title: strings.fieldLevel,
///   options: [for (final l in Level.values) AppSelectOption(l, levelText(strings, l))],
///   selected: level,
/// );
/// if (picked != null) setState(() => level = picked.value);
/// ```
Future<AppSelectResult<T>?> showAppSelectPopup<T>(
  BuildContext context, {
  required String title,
  required List<AppSelectOption<T>> options,
  required T? selected,
}) {
  return Navigator.of(context).push(
    _SelectPopupRoute<T>(
      title: title,
      options: options,
      selected: selected,
      barrierLabel: AppStrings.of(context).cancel,
    ),
  );
}

class _SelectPopupRoute<T> extends PopupRoute<AppSelectResult<T>> {
  _SelectPopupRoute({
    required this.title,
    required this.options,
    required this.selected,
    required this.barrierLabel,
  });

  final String title;
  final List<AppSelectOption<T>> options;
  final T? selected;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  // The blur and the dim are drawn by [buildTransitions], so they follow the same curve as the panel.
  @override
  Color? get barrierColor => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  /// How much the page behind is blurred, fully open.
  static const _blur = 14.0;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _SelectPanel<T>(title: title, options: options, selected: selected, animation: animation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final still = MediaQuery.disableAnimationsOf(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final dim = CupertinoDynamicColor.resolve(
      const CupertinoDynamicColor.withBrightness(color: Color(0x33000000), darkColor: Color(0x66000000)),
      context,
    );

    return Stack(
      children: [
        // The screen behind: blurred and dimmed together, never catching a tap (the route's barrier
        // under it does the closing).
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final t = curved.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blur * t, sigmaY: _blur * t),
                  child: ColoredBox(color: dim.withValues(alpha: dim.a * t)),
                );
              },
            ),
          ),
        ),
        // The panel: fades in, rises a little and grows from 94 %.
        FadeTransition(
          opacity: curved,
          child: still
              ? child
              : SlideTransition(
                  position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
                  child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
                ),
        ),
      ],
    );
  }
}

class _SelectPanel<T> extends StatelessWidget {
  const _SelectPanel({
    required this.title,
    required this.options,
    required this.selected,
    required this.animation,
  });

  final String title;
  final List<AppSelectOption<T>> options;
  final T? selected;
  final Animation<double> animation;

  static const _maxWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final size = MediaQuery.sizeOf(context);
    final material = AppColors.surface.resolveFrom(context).withValues(alpha: 0.86);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth, maxHeight: size.height * 0.7),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: AppRadii.lgRadius,
                boxShadow: [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 48, offset: Offset(0, 20)),
                  BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadii.lgRadius,
                // Frosted glass: the (already blurred) page shows through, blurred once more.
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: material,
                      borderRadius: AppRadii.lgRadius,
                      border: Border.all(color: AppColors.border.resolveFrom(context).withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.xs,
                          ),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.footnote.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.resolveFrom(context),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              return _Cascade(
                                animation: animation,
                                index: index,
                                child: _OptionRow(
                                  label: option.label,
                                  selected: option.value == selected,
                                  onTap: () => Navigator.of(context).pop(AppSelectResult<T>(option.value)),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.only(top: AppSpacing.xs),
                          color: AppColors.separator.resolveFrom(context),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            strings.cancel,
                            style: AppTypography.callout.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent.resolveFrom(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets row [index] arrive a beat after the one above it: a short fade and rise, staggered.
class _Cascade extends StatelessWidget {
  const _Cascade({required this.animation, required this.index, required this.child});

  final Animation<double> animation;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    // Rows past the eighth come in with the eighth, so a long list is not slow to open.
    final start = 0.15 + 0.06 * index.clamp(0, 8);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start.clamp(0.0, 0.8), 1, curve: Curves.easeOutCubic),
      // Closing: everything leaves together.
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

/// A choice: hover tint, the current one in the accent color with a check mark.
class _OptionRow extends StatefulWidget {
  const _OptionRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  var _hovered = false;
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent.resolveFrom(context);
    final background = _pressed
        ? AppColors.accentTint.resolveFrom(context)
        : _hovered
        ? AppColors.hover.resolveFrom(context)
        : const Color(0x00000000);

    return Semantics(
      button: true,
      selected: widget.selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            setState(() => _pressed = false);
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: AppDurations.of(context, AppDurations.micro),
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(color: background, borderRadius: AppRadii.smRadius),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.callout.copyWith(
                      fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                      color: widget.selected ? accent : AppColors.textPrimary.resolveFrom(context),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: widget.selected ? 1 : 0,
                  duration: AppDurations.of(context, AppDurations.micro),
                  child: Icon(AppIcons.check, size: 18, color: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
