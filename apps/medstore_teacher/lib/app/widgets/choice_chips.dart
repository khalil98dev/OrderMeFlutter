import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// A row of pill-shaped filters that scrolls sideways: "All", "Pending", "Ready"…
///
/// ```dart
/// ChoiceChips<OrderStatus?>(
///   options: {null: strings.filterAll, OrderStatus.ready: strings.orderStatusReady},
///   selected: filter.status,
///   onChanged: (status) => cubit.setFilter(MyOrdersFilter(status: status)),
/// )
/// ```
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({super.key, required this.options, required this.selected, required this.onChanged});

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final MapEntry(:key, :value) = options.entries.elementAt(index);
          return _Chip(label: value, selected: key == selected, onTap: () => onChanged(key));
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent.resolveFrom(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: AnimatedContainer(
          duration: AppDurations.of(context, AppDurations.selection),
          curve: AppDurations.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentFill.resolveFrom(context)
                : AppColors.surface.resolveFrom(context),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            border: Border.all(color: selected ? accent : AppColors.border.resolveFrom(context)),
          ),
          child: Text(
            label,
            style: AppTypography.subheadline.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onBrand : AppColors.textPrimary.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}
