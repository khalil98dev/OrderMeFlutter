import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/app/widgets/submit_dialog.dart';
import 'package:medstore_admin/features/teachers/domain/teacher.dart';
import 'package:medstore_admin/features/teachers/domain/teacher_repository.dart';
import 'package:medstore_admin/features/teachers/presentation/set_password_dialog.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Records the passwords it is asked to set.
class _FakeSetPassword implements SetTeacherPassword {
  final sent = <SetTeacherPasswordParams>[];

  @override
  Future<Result<void>> call(SetTeacherPasswordParams params) async {
    sent.add(params);
    return const Result.ok(null);
  }
}

final _teacher = Teacher(
  id: 't1',
  userId: 'u1',
  fullName: 'Amina Benali',
  isActive: true,
  createdAt: DateTime(2026, 11, 4),
);

void main() {
  late _FakeSetPassword setPassword;
  ({bool saved, void value})? outcome;

  Future<void> open(WidgetTester tester) async {
    setPassword = _FakeSetPassword();
    outcome = null;
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CupertinoApp(
        theme: AppTheme.cupertino,
        locale: const Locale('fr'),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates,
        home: Builder(
          builder: (context) => CupertinoButton(
            child: const Text('open'),
            onPressed: () async => outcome = await showSubmitDialog<void>(
              context,
              builder: (_) =>
                  SetPasswordDialog(teacher: _teacher, setPassword: setPassword, random: Random(7)),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.descendant(
    of: find.widgetWithText(AppTextField, label),
    matching: find.byType(CupertinoTextField),
  );

  testWidgets('asks for no current password, and refuses a short or mismatched one', (tester) async {
    await open(tester);
    expect(find.text('Nouveau mot de passe pour Amina Benali'), findsOneWidget);
    expect(find.text('Mot de passe actuel'), findsNothing);

    await tester.enterText(field('Nouveau mot de passe'), 'abc');
    await tester.enterText(field('Confirmer le mot de passe'), 'abd');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Le mot de passe doit contenir au moins 8 caractères.'), findsOneWidget);
    expect(find.text('Les deux mots de passe ne sont pas identiques.'), findsOneWidget);
    expect(setPassword.sent, isEmpty);
  });

  testWidgets('a typed password is sent for that teacher', (tester) async {
    await open(tester);
    await tester.enterText(field('Nouveau mot de passe'), 'Nouveau-2026');
    await tester.enterText(field('Confirmer le mot de passe'), 'Nouveau-2026');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(setPassword.sent.single.teacherId, 't1');
    expect(setPassword.sent.single.newPassword, 'Nouveau-2026');
    expect(outcome?.saved, isTrue);
  });

  testWidgets('"Générer" fills both fields with a readable 12-character password and shows it', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Copier'), findsNothing);

    await tester.tap(find.text('Générer'));
    await tester.pumpAndSettle();

    final generated = SetPasswordDialog.generate(Random(7));
    expect(generated, hasLength(SetPasswordDialog.generatedLength));
    expect(generated, isNot(matches(RegExp('[0O1lI]'))), reason: 'no look-alike characters');
    expect(find.text(generated), findsNWidgets(2), reason: 'shown in clear in both fields');
    expect(find.text('Copier'), findsOneWidget);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(setPassword.sent.single.newPassword, generated);
  });
}
