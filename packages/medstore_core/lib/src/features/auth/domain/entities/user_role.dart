/// Which app a user belongs to.
enum UserRole {
  /// The MedStore team: the `Admin` role or any staff role the admin creates. Uses the desktop app.
  admin,

  /// A teacher: the `Client` role. Uses the mobile app.
  client;

  /// Reads the role names from `/api/auth/me`. `Client` wins: a teacher is always limited to their own
  /// rows on the server, whatever else they are granted.
  static UserRole fromRoleNames(Iterable<String> roles) =>
      roles.any((role) => role.toLowerCase() == 'client') ? UserRole.client : UserRole.admin;
}
