import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// The teacher app's card: a large radius and a soft shadow instead of a hairline border, so cards
/// float on the grey canvas. In dark mode the shadow fades out and a hairline takes over.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = AppSpacing.card, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  static const radius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.resolveFrom(context),
          borderRadius: radius,
          border: dark ? Border.all(color: AppColors.border.resolveFrom(context), width: 0.5) : null,
          boxShadow: dark
              ? null
              : const [
                  BoxShadow(color: Color(0x0F12131A), blurRadius: 18, offset: Offset(0, 6)),
                  BoxShadow(color: Color(0x0A12131A), blurRadius: 3, offset: Offset(0, 1)),
                ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
