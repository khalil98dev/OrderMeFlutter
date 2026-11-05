import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Demo text in the current language. The gallery's sample data (order statuses, names) is not part of
/// the app strings, so it is written here in both languages.
String tr(BuildContext context, String fr, String ar) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : fr;

/// One group of the catalog: a title, the component names it shows, and the demos.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, required this.components, required this.children});

  final String title;

  /// The class names shown, so a developer can search for them.
  final String components;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(title: title, subtitle: components),
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: children),
        ],
      ),
    );
  }
}

/// A card with a small caption, holding one demo.
class Demo extends StatelessWidget {
  const Demo({super.key, required this.label, required this.child, this.width = 320});

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary.resolveFrom(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
