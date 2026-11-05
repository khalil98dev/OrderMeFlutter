import 'package:flutter/widgets.dart';

import 'app_segmented_control.dart';

/// Arabic / French switch. Each language is written in itself, so anyone can find theirs.
///
/// ```dart
/// LanguageSwitch(current: Localizations.localeOf(context), onChanged: localeCubit.choose)
/// ```
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key, required this.current, required this.onChanged});

  /// The language now shown on screen.
  final Locale current;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSegmentedControl<String>(
      segments: const {'ar': 'العربية', 'fr': 'Français'},
      selected: current.languageCode,
      onChanged: (code) => onChanged(Locale(code)),
    );
  }
}
