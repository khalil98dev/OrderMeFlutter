import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../router/admin_destinations.dart';

/// The signed-in frame: sidebar on the start side, the selected page beside it.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  var _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final shell = widget.shell;

    return CupertinoPageScaffold(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            title: strings.appName,
            subtitle: strings.adminSubtitle,
            collapsed: _collapsed,
            onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
            toggleLabel: _collapsed ? strings.expandSidebar : strings.collapseSidebar,
            selectedIndex: shell.currentIndex,
            // Tapping the current entry again goes back to that section's first page.
            onSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
            items: [
              for (final d in adminDestinations)
                AppSidebarItem(
                  label: d.label(strings),
                  icon: d.icon,
                  activeIcon: d.activeIcon,
                  section: d.section(strings),
                ),
            ],
            footer: (context, compact) => _UserFooter(compact: compact),
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

class _UserFooter extends StatelessWidget {
  const _UserFooter({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Rebuilds only when the user changes, not on every auth event.
    final user = context.select<AuthCubit, SessionUser?>(
      (cubit) => switch (cubit.state) {
        Authenticated(:final user) => user,
        _ => null,
      },
    );
    final name = user?.userName ?? '';
    final signOut = Tooltip(
      message: strings.signOut,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(32),
        onPressed: () => context.read<AuthCubit>().signOut(),
        child: Icon(
          CupertinoIcons.square_arrow_right,
          size: 18,
          color: AppColors.textSecondary.resolveFrom(context),
          semanticLabel: strings.signOut,
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.separator.resolveFrom(context), width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(name: name),
                  signOut,
                ],
              )
            : Row(
                children: [
                  _Avatar(name: name),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.resolveFrom(context),
                      ),
                    ),
                  ),
                  signOut,
                ],
              ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.brandTint.resolveFrom(context), shape: BoxShape.circle),
      child: Text(
        name.isEmpty ? '' : name.characters.first.toUpperCase(),
        style: AppTypography.headline.copyWith(fontSize: 14, color: AppColors.brand.resolveFrom(context)),
      ),
    );
  }
}
