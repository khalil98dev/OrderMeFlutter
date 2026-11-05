import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../router/teacher_router.dart';

/// The signed-in frame: the selected tab above an iOS tab bar.
class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: shell),
          CupertinoTabBar(
            currentIndex: shell.currentIndex,
            activeColor: AppColors.brand.resolveFrom(context),
            // Tapping the current tab again goes back to its first page.
            onTap: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
            items: [
              for (final tab in teacherTabs)
                BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label(strings),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
