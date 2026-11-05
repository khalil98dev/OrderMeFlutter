import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../router/teacher_router.dart';
import 'teacher_page.dart';

/// Stands in for a tab until its feature is built.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.tab});

  final TeacherTab tab;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return TeacherPage(
      title: tab.label(strings),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: tab.icon,
            title: strings.comingSoonTitle,
            message: strings.comingSoonMessage,
          ),
        ),
      ],
    );
  }
}
