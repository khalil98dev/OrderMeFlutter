import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// The frame of every admin page: the page header, then the page body under it.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  /// A sub-page (a detail opened from a list) shows a back button that calls this.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenDesktop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(title: title, subtitle: subtitle, actions: actions, onBack: onBack),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
