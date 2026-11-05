import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/widgets/submit_dialog.dart';
import '../domain/security.dart';

/// A new role (it starts with no permissions).
class NewRoleDialog extends StatefulWidget {
  const NewRoleDialog({super.key, required this.createRole});

  final CreateRole createRole;

  @override
  State<NewRoleDialog> createState() => _NewRoleDialogState();
}

class _NewRoleDialogState extends State<NewRoleDialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  var _nameMissing = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SubmitDialog<void>(
      title: strings.newRole,
      prepare: () {
        setState(() => _nameMissing = _name.text.trim().isEmpty);
        if (_nameMissing) return null;
        return () => widget.createRole(CreateRoleParams(_name.text, _description.text));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: strings.fieldRoleName,
            controller: _name,
            isRequired: true,
            autofocus: true,
            errorText: _nameMissing ? strings.fieldRequired : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: strings.fieldDescription, controller: _description, maxLines: 2),
        ],
      ),
    );
  }
}

/// Ticks for each role; the teachers' role is left out (its accounts are made in Teachers).
class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.roles, required this.selected, required this.onChanged, this.error});

  final List<String> roles;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(strings.fieldRoles, isRequired: true),
        Wrap(
          spacing: AppSpacing.md,
          children: [
            for (final role in roles)
              if (role != Role.clientName)
                AppCheckbox(
                  label: role,
                  value: selected.contains(role),
                  onChanged: (checked) =>
                      onChanged(checked ? {...selected, role} : ({...selected}..remove(role))),
                ),
          ],
        ),
        if (error != null) AppMessage(text: error),
      ],
    );
  }
}

/// A staff account with its roles.
class NewUserDialog extends StatefulWidget {
  const NewUserDialog({super.key, required this.createUser, required this.roles});

  final CreateUser createUser;
  final List<String> roles;

  @override
  State<NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<NewUserDialog> {
  final _userName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  Set<String> _roles = const {};
  Set<UserDraftField> _problems = const {};

  @override
  void dispose() {
    _userName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    return SubmitDialog<void>(
      title: strings.newUser,
      prepare: () {
        final draft = UserDraft(
          userName: _userName.text,
          email: _email.text,
          password: _password.text,
          roles: _roles,
        );
        setState(() => _problems = draft.validate());
        if (_problems.isNotEmpty) return null;
        return () => widget.createUser(draft);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessage(text: strings.teacherAccountsHint, tone: AppTone.info),
          gap,
          AppTextField(
            label: strings.userName,
            controller: _userName,
            isRequired: true,
            autofocus: true,
            errorText: _problems.contains(UserDraftField.userName) ? strings.fieldRequired : null,
          ),
          gap,
          AppTextField(
            label: strings.fieldEmail,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          gap,
          AppTextField(
            label: strings.password,
            controller: _password,
            obscure: true,
            isRequired: true,
            errorText: _problems.contains(UserDraftField.password) ? strings.validationPassword : null,
          ),
          gap,
          _RolePicker(
            roles: widget.roles,
            selected: _roles,
            onChanged: (roles) => setState(() => _roles = roles),
            error: _problems.contains(UserDraftField.roles) ? strings.chooseRoles : null,
          ),
        ],
      ),
    );
  }
}

/// Replaces a user's roles (they are signed out everywhere).
class UserRolesDialog extends StatefulWidget {
  const UserRolesDialog({super.key, required this.user, required this.roles, required this.setRoles});

  final AdminUser user;
  final List<String> roles;
  final SetUserRoles setRoles;

  @override
  State<UserRolesDialog> createState() => _UserRolesDialogState();
}

class _UserRolesDialogState extends State<UserRolesDialog> {
  late Set<String> _roles = widget.user.roles.toSet();
  var _empty = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SubmitDialog<void>(
      title: strings.rolesOf(widget.user.userName),
      prepare: () {
        setState(() => _empty = _roles.isEmpty);
        if (_empty) return null;
        return () => widget.setRoles(SetUserRolesParams(widget.user.userId, _roles));
      },
      child: _RolePicker(
        roles: widget.roles,
        selected: _roles,
        onChanged: (roles) => setState(() => _roles = roles),
        error: _empty ? strings.chooseRoles : null,
      ),
    );
  }
}
