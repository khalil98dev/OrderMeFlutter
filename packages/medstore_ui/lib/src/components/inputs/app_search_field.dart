import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';

/// A search box that waits until the user stops typing before reporting the query.
///
/// ```dart
/// AppSearchField(onChanged: (query) => cubit.search(query))
/// ```
///
/// [onChanged] fires [debounce] after the last keystroke (one API call per pause, not per letter);
/// clearing the box and pressing Enter report at once.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.placeholder,
    this.controller,
    this.debounce = const Duration(milliseconds: 300),
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;

  /// Defaults to "Search" in the user's language.
  final String? placeholder;
  final TextEditingController? controller;
  final Duration debounce;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _timer;
  String _lastReported = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _typed(String query) {
    _timer?.cancel();
    if (query.isEmpty) return _report(query);
    _timer = Timer(widget.debounce, () => _report(query));
  }

  void _report(String query) {
    _timer?.cancel();
    final trimmed = query.trim();
    if (trimmed == _lastReported) return; // "abc" → "abcd" → "abc" within the pause: nothing changed
    _lastReported = trimmed;
    widget.onChanged(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      placeholder: widget.placeholder ?? AppStrings.of(context).search,
      onChanged: _typed,
      onSubmitted: _report,
      // The built-in clear button empties the box and calls onChanged('') → reported at once.
    );
  }
}
