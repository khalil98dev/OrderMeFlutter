import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';

void main() {
  test('Client role means the teacher app, whatever else is granted', () {
    expect(UserRole.fromRoleNames(['Client']), UserRole.client);
    expect(UserRole.fromRoleNames(['Reviewer', 'Client']), UserRole.client);
  });

  test('Admin and staff roles mean the admin app', () {
    expect(UserRole.fromRoleNames(['Admin']), UserRole.admin);
    expect(UserRole.fromRoleNames(['Printer']), UserRole.admin);
  });
}
