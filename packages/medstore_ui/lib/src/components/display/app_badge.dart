import 'package:flutter/cupertino.dart';

import '../../tokens/app_metrics.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// A small colored pill: a status, a count, a tag.
///
/// ```dart
/// AppBadge(label: strings.statusReady, tone: AppTone.success)
/// AppBadge(label: strings.statusPending, tone: AppTone.warning, icon: AppIcons.clock)
/// ```
///
/// Map your domain value to a tone in the feature (for example `OrderStatus.ready → AppTone.success`),
/// so the badge stays free of business rules.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppTone.neutral, this.icon});

  final String label;
  final AppTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: colors.foreground), const SizedBox(width: 4)],
            // Flexible: in a narrow column the label ends with "…" instead of overflowing.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: colors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
