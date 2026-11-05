import 'package:flutter/cupertino.dart';

import '../../tokens/app_metrics.dart';

/// Picks one value among a few (2-5) shown side by side: a status filter, a period, a language.
///
/// ```dart
/// AppSegmentedControl<OrderFilter>(
///   segments: {OrderFilter.open: strings.open, OrderFilter.ready: strings.ready, OrderFilter.all: strings.all},
///   selected: state.filter,
///   onChanged: cubit.filterBy,
/// )
/// ```
///
/// Segments appear in the map's order (Dart maps keep insertion order) and mirror in Arabic.
class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: selected,
      onValueChanged: (value) {
        if (value != null) onChanged(value);
      },
      children: {
        for (final MapEntry(key: value, value: label) in segments.entries)
          value: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            child: Text(label, maxLines: 1),
          ),
      },
    );
  }
}
