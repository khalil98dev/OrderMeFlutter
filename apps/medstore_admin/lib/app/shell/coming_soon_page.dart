import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../router/admin_destinations.dart';
import 'admin_page.dart';

/// Stands in for a section until its feature is built.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.destination});

  final AdminDestination destination;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AdminPage(
      title: destination.label(strings),
      child: AppEmptyState(
        icon: destination.icon,
        title: strings.comingSoonTitle,
        message: strings.comingSoonMessage,
      ),
    );
  }
}
