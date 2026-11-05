import 'package:equatable/equatable.dart';
import 'package:medstore_core/medstore_core.dart';

/// What can be done to a resource. Sent as flag names joined by ", " ("Read, Set").
enum ResourceAction {
  create('Create'),
  read('Read'),
  set('Set'),
  delete('Delete');

  const ResourceAction(this.apiName);

  final String apiName;
}

/// What can be done to a secured field.
enum FieldAction {
  read('Read'),
  set('Set');

  const FieldAction(this.apiName);

  final String apiName;
}

/// Reads a flags value: "Read, Set", "All" or "None".
Set<T> parseFlags<T extends Enum>(String? value, List<T> all, String Function(T) apiName) {
  if (value == null) return {};
  final names = value.split(',').map((name) => name.trim()).toSet();
  if (names.contains('All')) return all.toSet();
  return {
    for (final action in all)
      if (names.contains(apiName(action))) action,
  };
}

/// Writes a flags value in the enum's order; "None" when empty.
String formatFlags<T extends Enum>(Set<T> actions, List<T> all, String Function(T) apiName) {
  final names = [
    for (final action in all)
      if (actions.contains(action)) apiName(action),
  ];
  return names.isEmpty ? 'None' : names.join(', ');
}

Set<ResourceAction> parseResourceActions(String? value) =>
    parseFlags(value, ResourceAction.values, (action) => action.apiName);

Set<FieldAction> parseFieldActions(String? value) =>
    parseFlags(value, FieldAction.values, (action) => action.apiName);

/// A securable resource, its actions and secured fields (generated from the server's configuration).
final class SecuredResource extends Equatable {
  const SecuredResource({required this.name, required this.actions, required this.fields});

  final String name;
  final Set<ResourceAction> actions;

  /// Field name → the actions that can be granted on it.
  final Map<String, Set<FieldAction>> fields;

  @override
  List<Object?> get props => [name, actions, fields];
}

/// What a role is granted on one resource.
final class Grant extends Equatable {
  const Grant({required this.resource, required this.actions, this.fields = const {}});

  final String resource;
  final Set<ResourceAction> actions;
  final Map<String, Set<FieldAction>> fields;

  @override
  List<Object?> get props => [resource, actions, fields];
}

final class Role extends Equatable {
  const Role({required this.name, required this.description, required this.grants});

  /// The role the server re-grants everything at each start.
  static const adminName = 'Admin';

  /// The teachers' role: its accounts are managed in Teachers.
  static const clientName = 'Client';

  final String name;
  final String description;
  final List<Grant> grants;

  @override
  List<Object?> get props => [name, description, grants];
}

/// One cell group of the permissions grid: what could be granted, and what is.
final class FieldMatrix extends Equatable {
  const FieldMatrix({required this.name, required this.available, required this.granted});

  final String name;
  final Set<FieldAction> available;
  final Set<FieldAction> granted;

  FieldMatrix toggled(FieldAction action) => FieldMatrix(
    name: name,
    available: available,
    granted: granted.contains(action) ? ({...granted}..remove(action)) : {...granted, action},
  );

  @override
  List<Object?> get props => [name, available, granted];
}

final class ResourceMatrix extends Equatable {
  const ResourceMatrix({
    required this.name,
    required this.available,
    required this.granted,
    required this.fields,
  });

  final String name;
  final Set<ResourceAction> available;
  final Set<ResourceAction> granted;
  final List<FieldMatrix> fields;

  bool get hasAnything => granted.isNotEmpty || fields.any((field) => field.granted.isNotEmpty);

  ResourceMatrix toggled(ResourceAction action) => ResourceMatrix(
    name: name,
    available: available,
    granted: granted.contains(action) ? ({...granted}..remove(action)) : {...granted, action},
    fields: fields,
  );

  ResourceMatrix fieldToggled(String field, FieldAction action) => ResourceMatrix(
    name: name,
    available: available,
    granted: granted,
    fields: [for (final f in fields) f.name == field ? f.toggled(action) : f],
  );

  @override
  List<Object?> get props => [name, available, granted, fields];
}

/// One role against every securable resource. Saved as one [Grant] per resource with anything ticked.
final class RoleMatrix extends Equatable {
  const RoleMatrix({required this.role, required this.description, required this.resources});

  final String role;
  final String description;
  final List<ResourceMatrix> resources;

  RoleMatrix toggled(String resource, ResourceAction action) => _with(resource, (r) => r.toggled(action));

  RoleMatrix fieldToggled(String resource, String field, FieldAction action) =>
      _with(resource, (r) => r.fieldToggled(field, action));

  RoleMatrix _with(String resource, ResourceMatrix Function(ResourceMatrix) change) => RoleMatrix(
    role: role,
    description: description,
    resources: [for (final r in resources) r.name == resource ? change(r) : r],
  );

  List<Grant> toGrants() => [
    for (final resource in resources)
      if (resource.hasAnything)
        Grant(
          resource: resource.name,
          actions: resource.granted,
          fields: {
            for (final field in resource.fields)
              if (field.granted.isNotEmpty) field.name: field.granted,
          },
        ),
  ];

  @override
  List<Object?> get props => [role, description, resources];
}

/// A sign-in account (staff or teacher).
final class AdminUser extends Equatable {
  const AdminUser({
    required this.userId,
    required this.userName,
    required this.isActive,
    required this.roles,
    this.email,
  });

  final String userId;
  final String userName;
  final String? email;
  final bool isActive;
  final List<String> roles;

  bool get isTeacher => roles.contains(Role.clientName);

  @override
  List<Object?> get props => [userId, userName, email, isActive, roles];
}

enum UserDraftField { userName, password, roles }

final class UserDraft extends Equatable {
  const UserDraft({required this.userName, required this.password, this.email = '', this.roles = const {}});

  final String userName;
  final String email;
  final String password;
  final Set<String> roles;

  Set<UserDraftField> validate() => {
    if (userName.trim().isEmpty) UserDraftField.userName,
    if (password.length < ChangePassword.minLength) UserDraftField.password,
    if (roles.isEmpty) UserDraftField.roles,
  };

  @override
  List<Object?> get props => [userName, email, password, roles];
}

/// `/api/admin/security`, `/api/admin/roles` and `/api/admin/users` (Admin role only).
abstract interface class SecurityRepository {
  Future<Result<List<SecuredResource>>> resources();

  Future<Result<List<Role>>> roles();

  /// A new role starts with no permissions.
  Future<Result<void>> createRole(String name, String description);

  Future<Result<RoleMatrix>> matrix(String role);

  /// Replaces every permission of the role. Every invalid grant comes back at once (400).
  Future<Result<void>> setPermissions(String role, List<Grant> grants);

  Future<Result<List<AdminUser>>> users();

  Future<Result<void>> createUser(UserDraft draft);

  /// Replaces the user's roles and signs them out everywhere.
  Future<Result<void>> setUserRoles(String userId, Set<String> roles);

  Future<Result<void>> deactivateUser(String userId);
}

class ListSecuredResources implements UseCase<List<SecuredResource>, NoParams> {
  const ListSecuredResources(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<List<SecuredResource>>> call(NoParams params) => _repository.resources();
}

class ListRoles implements UseCase<List<Role>, NoParams> {
  const ListRoles(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<List<Role>>> call(NoParams params) => _repository.roles();
}

final class CreateRoleParams {
  const CreateRoleParams(this.name, this.description);

  final String name;
  final String description;
}

class CreateRole implements UseCase<void, CreateRoleParams> {
  const CreateRole(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<void>> call(CreateRoleParams params) =>
      _repository.createRole(params.name.trim(), params.description.trim());
}

class GetRoleMatrix implements UseCase<RoleMatrix, String> {
  const GetRoleMatrix(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<RoleMatrix>> call(String role) => _repository.matrix(role);
}

/// Saves the grid as edited: one grant per resource with anything ticked.
class SaveRoleMatrix implements UseCase<void, RoleMatrix> {
  const SaveRoleMatrix(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<void>> call(RoleMatrix matrix) => _repository.setPermissions(matrix.role, matrix.toGrants());
}

class ListUsers implements UseCase<List<AdminUser>, NoParams> {
  const ListUsers(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<List<AdminUser>>> call(NoParams params) => _repository.users();
}

class CreateUser implements UseCase<void, UserDraft> {
  const CreateUser(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<void>> call(UserDraft draft) => _repository.createUser(draft);
}

final class SetUserRolesParams {
  const SetUserRolesParams(this.userId, this.roles);

  final String userId;
  final Set<String> roles;
}

class SetUserRoles implements UseCase<void, SetUserRolesParams> {
  const SetUserRoles(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<void>> call(SetUserRolesParams params) =>
      _repository.setUserRoles(params.userId, params.roles);
}

class DeactivateUser implements UseCase<void, String> {
  const DeactivateUser(this._repository);

  final SecurityRepository _repository;

  @override
  Future<Result<void>> call(String userId) => _repository.deactivateUser(userId);
}
