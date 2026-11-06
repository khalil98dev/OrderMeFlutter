import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';

/// A book cover (or any picture) with a rounded frame, a fade-in, and a placeholder when there is no
/// image or it fails to load.
///
/// ```dart
/// AppCoverImage(image: productImages.cover(product), width: 56)          // a list thumbnail
/// AppCoverImage(image: productImages.cover(product), width: 220)         // a detail page
/// ```
///
/// The image is decoded at the size it is shown ([width] × the screen's pixel ratio), so a large cover
/// costs a thumbnail's memory in a list. Height follows the book's 3:4 shape unless [height] is given.
class AppCoverImage extends StatelessWidget {
  const AppCoverImage({
    super.key,
    required this.image,
    required this.width,
    this.height,
    this.placeholderIcon = AppIcons.products,
    this.semanticLabel,
  });

  final ImageProvider? image;
  final double width;
  final double? height;
  final IconData placeholderIcon;
  final String? semanticLabel;

  double get _height => height ?? width * 4 / 3;

  @override
  Widget build(BuildContext context) {
    final radius = width < 80 ? AppRadii.xsRadius : AppRadii.mdRadius;
    final image = this.image;
    final placeholder = _Placeholder(icon: placeholderIcon, iconSize: width * 0.4);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: _height,
        child: image == null
            ? placeholder
            : Image(
                image: ResizeImage(
                  image,
                  width: (width * MediaQuery.devicePixelRatioOf(context)).round(),
                  allowUpscaling: false,
                ),
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
                // Placeholder while loading, then a short fade (skipped when the image was cached).
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedSwitcher(
                    duration: AppDurations.of(context, AppDurations.selection),
                    child: frame == null ? placeholder : child,
                  );
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.iconSize});

  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.accentTint.resolveFrom(context),
      child: Center(
        child: Icon(icon, size: iconSize, color: AppColors.accent.resolveFrom(context)),
      ),
    );
  }
}
