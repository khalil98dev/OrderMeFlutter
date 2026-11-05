import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';
import '../surfaces/pressable.dart';

/// One row of a list: optional leading widget, a title, an optional subtitle, and a trailing widget.
///
/// ```dart
/// AppListTile(
///   leading: AppAvatar(name: teacher.name),
///   title: teacher.name,
///   subtitle: teacher.school,
///   trailing: AppBadge(label: strings.active, tone: AppTone.success),
///   onTap: () => openTeacher(teacher.id),
/// )
/// ```
///
/// A tappable row shows a chevron (pointing the reading direction, so it flips in Arabic) unless
/// [showChevron] says otherwise. Put rows in an `AppSection` for the grouped iOS look.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to "only when tappable".
  final bool? showChevron;

  /// Red title, for rows like "Sign out" or "Delete".
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final chevron = showChevron ?? onTap != null;
    final titleColor = destructive ? AppColors.destructive : AppColors.textPrimary;

    return Pressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.sm)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(color: titleColor.resolveFrom(context)),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.textSecondary.resolveFrom(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: AppSpacing.sm), trailing!],
              if (chevron) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: AppColors.textTertiary.resolveFrom(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
