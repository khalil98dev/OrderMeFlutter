import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// A titled group of rows in one rounded card, separated by hairlines (the iOS Settings look).
///
/// ```dart
/// AppSection(
///   header: strings.account,
///   footer: strings.passwordHint,
///   children: [
///     AppListTile(title: strings.changePassword, onTap: changePassword),
///     AppListTile(title: strings.signOut, destructive: true, onTap: signOut),
///   ],
/// )
/// ```
///
/// For a long or growing list use a `SliverList.builder` instead: a section builds all its rows at once.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.dividerIndent = AppSpacing.md,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;

  /// Where separators start; set it past a leading icon or avatar so lines align with the titles.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final secondary = AppColors.textSecondary.resolveFrom(context);
    final separator = AppColors.separator.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.md, bottom: 6),
            child: Text(header!.toUpperCase(), style: AppTypography.footnote.copyWith(color: secondary)),
          ),
        ClipRRect(
          borderRadius: AppRadii.mdRadius,
          child: ColoredBox(
            color: AppColors.surface.resolveFrom(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: dividerIndent),
                      child: SizedBox(height: 0.5, child: ColoredBox(color: separator)),
                    ),
                  child,
                ],
              ],
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.md, end: AppSpacing.md, top: 6),
            child: Text(footer!, style: AppTypography.footnote.copyWith(color: secondary)),
          ),
      ],
    );
  }
}
