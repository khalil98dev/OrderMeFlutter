import 'package:medstore_core/medstore_core.dart';

import '../../../app/forms/form_values.dart';
import '../domain/security.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  const SecurityRepositoryImpl(this._api);

  static const _admin = '/api/admin';

  final ApiClient _api;

  @override
  Future<Result<List<SecuredResource>>> resources() => _api.get(
    '$_admin/security/resources',
    decode: (json) => [
      for (final raw in json! as List<Object?>)
        () {
          final resource = JsonMap.of(raw);
          return SecuredResource(
            name: resource.string('name'),
            actions: _resourceActionsList(resource['actions']),
            fields: {
              for (final field in resource.list('fields', JsonMap.of))
                field.string('name'): _fieldActionsList(field['actions']),
            },
          );
        }(),
    ],
  );

  @override
  Future<Result<List<Role>>> roles() => _api.get(
    '$_admin/roles',
    decode: (json) => [
      for (final raw in json! as List<Object?>)
        () {
          final role = JsonMap.of(raw);
          return Role(
            name: role.string('name'),
            description: role.stringOrNull('description') ?? '',
            grants: role.list('grants', (raw) {
              final grant = JsonMap.of(raw);
              return Grant(
                resource: grant.string('resource'),
                actions: parseResourceActions(grant.stringOrNull('actions')),
                fields: grant
                    .stringMap('fields')
                    .map((field, actions) => MapEntry(field, parseFieldActions(actions))),
              );
            }),
          );
        }(),
    ],
  );

  @override
  Future<Result<void>> createRole(String name, String description) => _api.post(
    '$_admin/roles',
    data: {'name': name, 'description': description},
    decode: ApiClient.ignoreBody,
  );

  @override
  Future<Result<RoleMatrix>> matrix(String role) => _api.get(
    '$_admin/security/roles/${Uri.encodeComponent(role)}/matrix',
    decode: (raw) {
      final json = JsonMap.of(raw);
      return RoleMatrix(
        role: json.string('role'),
        description: json.stringOrNull('description') ?? '',
        resources: json.list('resources', (raw) {
          final resource = JsonMap.of(raw);
          return ResourceMatrix(
            name: resource.string('name'),
            available: _resourceActionsList(resource['available']),
            granted: _resourceActionsList(resource['granted']),
            fields: resource.list('fields', (raw) {
              final field = JsonMap.of(raw);
              return FieldMatrix(
                name: field.string('name'),
                available: _fieldActionsList(field['available']),
                granted: _fieldActionsList(field['granted']),
              );
            }),
          );
        }),
      );
    },
  );

  @override
  Future<Result<void>> setPermissions(String role, List<Grant> grants) => _api.put(
    '$_admin/roles/${Uri.encodeComponent(role)}/permissions',
    data: [
      for (final grant in grants)
        {
          'resource': grant.resource,
          'actions': formatFlags(grant.actions, ResourceAction.values, (a) => a.apiName),
          'fields': {
            for (final MapEntry(key: field, value: actions) in grant.fields.entries)
              field: formatFlags(actions, FieldAction.values, (a) => a.apiName),
          },
        },
    ],
    decode: ApiClient.ignoreBody,
  );

  @override
  Future<Result<List<AdminUser>>> users() => _api.get(
    '$_admin/users',
    decode: (json) => [
      for (final raw in json! as List<Object?>)
        () {
          final user = JsonMap.of(raw);
          return AdminUser(
            userId: user.string('userId'),
            userName: user.string('userName'),
            email: user.stringOrNull('email'),
            isActive: user.boolean('isActive'),
            roles: user.list('roles', (role) => role! as String),
          );
        }(),
    ],
  );

  @override
  Future<Result<void>> createUser(UserDraft draft) => _api.post(
    '$_admin/users',
    data: {
      'userName': draft.userName.trim(),
      'email': optionalText(draft.email),
      'password': draft.password,
      'roles': draft.roles.toList(),
    },
    decode: ApiClient.ignoreBody,
  );

  @override
  Future<Result<void>> setUserRoles(String userId, Set<String> roles) =>
      _api.put('$_admin/users/$userId/roles', data: {'roles': roles.toList()}, decode: ApiClient.ignoreBody);

  @override
  Future<Result<void>> deactivateUser(String userId) =>
      _api.post('$_admin/users/$userId/deactivate', decode: ApiClient.ignoreBody);

  /// The matrix and resources endpoints send action lists (`["Read", "Set"]`), or a flags string.
  static Set<ResourceAction> _resourceActionsList(Object? value) => switch (value) {
    final List<Object?> names => parseResourceActions(names.join(', ')),
    final String flags => parseResourceActions(flags),
    _ => const {},
  };

  static Set<FieldAction> _fieldActionsList(Object? value) => switch (value) {
    final List<Object?> names => parseFieldActions(names.join(', ')),
    final String flags => parseFieldActions(flags),
    _ => const {},
  };
}
