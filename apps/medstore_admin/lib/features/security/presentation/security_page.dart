import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/security.dart';
import 'security_dialogs.dart';

enum _Tab { roles, users, resources }

/// Who may do what: roles (and their permission grids), staff accounts, and the securable resources.
///
/// Expects `LoadCubit`s of `List<Role>`, `List<AdminUser>` and `List<SecuredResource>`, and the
/// security use cases above it.
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  var _tab = _Tab.roles;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AdminPage(
      title: strings.navSecurity,
      actions: [
        AppSegmentedControl<_Tab>(
          segments: {
            _Tab.roles: strings.tabRoles,
            _Tab.users: strings.tabUsers,
            _Tab.resources: strings.tabResources,
          },
          selected: _tab,
          onChanged: (tab) => setState(() => _tab = tab),
        ),
        if (_tab == _Tab.roles)
          AppButton(label: strings.newRole, icon: CupertinoIcons.add, onPressed: () => _newRole(context)),
        if (_tab == _Tab.users)
          AppButton(label: strings.newUser, icon: CupertinoIcons.add, onPressed: () => _newUser(context)),
      ],
      child: switch (_tab) {
        _Tab.roles => const _RolesTab(),
        _Tab.users => const _UsersTab(),
        _Tab.resources => const _ResourcesTab(),
      },
    );
  }

  Future<void> _newRole(BuildContext context) async {
    final strings = AppStrings.of(context);
    final create = context.read<CreateRole>();
    final roles = context.read<LoadCubit<List<Role>>>();
    final result = await showSubmitDialog<void>(context, builder: (_) => NewRoleDialog(createRole: create));
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.roleCreated, tone: AppTone.success);
    await roles.load();
  }

  Future<void> _newUser(BuildContext context) async {
    final strings = AppStrings.of(context);
    final create = context.read<CreateUser>();
    final users = context.read<LoadCubit<List<AdminUser>>>();
    final roleNames = _roleNames(context);
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => NewUserDialog(createUser: create, roles: roleNames),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.userCreated, tone: AppTone.success);
    await users.load();
  }
}

List<String> _roleNames(BuildContext context) => [
  for (final role in context.read<LoadCubit<List<Role>>>().state.data ?? const <Role>[]) role.name,
];

/// The shared loading, error and empty handling of the three tabs.
class _ListView<T> extends StatelessWidget {
  const _ListView({required this.builder, required this.icon});

  final Widget Function(BuildContext context, List<T> items) builder;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<List<T>>>();
    final state = context.watch<LoadCubit<List<T>>>().state;
    final items = state.data ?? <T>[];
    return AppLoadView(
      isLoading: state.isLoading || (!state.hasData && state.failure == null),
      hasData: items.isNotEmpty,
      failure: state.failure,
      onRetry: cubit.load,
      empty: AppEmptyState(icon: icon, title: strings.noResultsTitle),
      builder: (context) => builder(context, items),
    );
  }
}

class _RolesTab extends StatelessWidget {
  const _RolesTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return _ListView<Role>(
      icon: CupertinoIcons.lock_shield,
      builder: (context, roles) => AppTable(
        columns: [
          AppTableColumn(strings.fieldRoleName, width: 200),
          AppTableColumn(strings.fieldDescription, flex: 3),
          AppTableColumn(strings.tabResources, width: 200),
        ],
        rowCount: roles.length,
        onRowTap: (index) => context.push('/security/roles/${Uri.encodeComponent(roles[index].name)}'),
        cells: (context, index) {
          final role = roles[index];
          return [
            Text(role.name, style: AppTypography.headline),
            Text(role.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            AppBadge(label: strings.grantsCount(role.grants.length), tone: AppTone.info),
          ];
        },
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return _ListView<AdminUser>(
      icon: CupertinoIcons.person_2,
      builder: (context, users) => AppTable(
        columns: [
          AppTableColumn(strings.userName, flex: 2),
          AppTableColumn(strings.fieldEmail, flex: 2),
          AppTableColumn(strings.fieldRoles, flex: 2),
          AppTableColumn(strings.fieldStatus, width: 100),
          const AppTableColumn('', width: 84),
        ],
        rowCount: users.length,
        cells: (context, index) {
          final user = users[index];
          return [
            Row(
              children: [
                AppAvatar(name: user.userName, size: 32),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(user.userName, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            Text(user.email ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(user.roles.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis),
            AppBadge(
              label: user.isActive ? strings.active : strings.inactive,
              tone: user.isActive ? AppTone.success : AppTone.neutral,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Teachers' accounts are managed with the teacher.
                if (!user.isTeacher)
                  AppIconButton(
                    icon: CupertinoIcons.lock_shield,
                    label: strings.editRoles,
                    onPressed: () => _editRoles(context, user),
                  ),
                if (user.isActive && !user.isTeacher)
                  AppIconButton(
                    icon: CupertinoIcons.person_crop_circle_badge_xmark,
                    label: strings.deactivate,
                    tone: AppTone.danger,
                    onPressed: () => _deactivate(context, user),
                  ),
              ],
            ),
          ];
        },
      ),
    );
  }

  static Future<void> _editRoles(BuildContext context, AdminUser user) async {
    final strings = AppStrings.of(context);
    final setRoles = context.read<SetUserRoles>();
    final users = context.read<LoadCubit<List<AdminUser>>>();
    final roleNames = _roleNames(context);
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => UserRolesDialog(user: user, roles: roleNames, setRoles: setRoles),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.rolesSaved, tone: AppTone.success);
    await users.load();
  }

  static Future<void> _deactivate(BuildContext context, AdminUser user) async {
    final strings = AppStrings.of(context);
    final deactivate = context.read<DeactivateUser>();
    final users = context.read<LoadCubit<List<AdminUser>>>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: strings.deactivateUserTitle(user.userName),
      message: strings.deactivateUserMessage,
      confirmLabel: strings.deactivate,
      destructive: true,
    );
    if (!confirmed) return;
    final result = await deactivate(user.userId);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.userDeactivated, tone: AppTone.success);
        await users.load();
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return _ListView<SecuredResource>(
      icon: CupertinoIcons.cube_box,
      builder: (context, resources) => AppTable(
        rowHeight: 64,
        columns: [
          AppTableColumn(strings.resourceCol, width: 200),
          AppTableColumn(strings.colType, flex: 2),
          AppTableColumn(strings.securedFields, flex: 3),
        ],
        rowCount: resources.length,
        cells: (context, index) {
          final resource = resources[index];
          return [
            Text(resource.name, style: AppTypography.headline),
            Text(
              [
                for (final action in ResourceAction.values)
                  if (resource.actions.contains(action)) resourceActionText(strings, action),
              ].join(', '),
            ),
            Text(
              resource.fields.isEmpty
                  ? '—'
                  : resource.fields.entries
                        .map(
                          (field) =>
                              '${field.key} (${field.value.map((action) => fieldActionText(strings, action)).join(', ')})',
                        )
                        .join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ];
        },
      ),
    );
  }
}
