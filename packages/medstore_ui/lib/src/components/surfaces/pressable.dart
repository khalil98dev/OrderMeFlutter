import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';

/// Makes any surface tappable the same way everywhere: a pointer cursor and a light highlight on hover
/// (desktop), a darker one while pressed (touch), and a "button" for screen readers.
///
/// With a null [onTap] it draws [child] unchanged, so a card or a row can be tappable or not with the
/// same code.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  var _hovered = false;
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    if (onTap == null) return widget.child;

    final hover = AppColors.hover.resolveFrom(context);
    final overlay = _pressed
        ? hover.withValues(alpha: hover.a * 2.5)
        : _hovered
        ? hover
        : const Color(0x00000000);

    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: AnimatedContainer(
            duration: AppDurations.of(context, AppDurations.micro),
            foregroundDecoration: BoxDecoration(color: overlay, borderRadius: widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
