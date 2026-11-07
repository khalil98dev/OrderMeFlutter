import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/widgets/submit_dialog.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';

enum _Problem { tooShort, mismatch }

/// Gives a teacher a new password when they forgot theirs: no current password, and every session of
/// theirs ends. "Generate" fills in a strong one and shows it, so it can be copied and handed over.
class SetPasswordDialog extends StatefulWidget {
  const SetPasswordDialog({super.key, required this.teacher, required this.setPassword, this.random});

  final Teacher teacher;
  final SetTeacherPassword setPassword;

  /// Source of generated passwords; secure by default (tests pass a seeded one).
  final Random? random;

  /// Letters and digits that cannot be misread when read aloud or copied by hand (no 0/O, 1/l/I).
  static const _alphabet = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Long enough to be well past the minimum, short enough to type on a phone.
  static const generatedLength = 12;

  static String generate(Random random) =>
      List.generate(generatedLength, (_) => _alphabet[random.nextInt(_alphabet.length)]).join();

  @override
  State<SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<SetPasswordDialog> {
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  late final Random _random = widget.random ?? Random.secure();
  Set<_Problem> _problems = const {};

  /// A generated password is shown in clear (it is meant to be read out); a typed one stays hidden.
  var _generated = false;

  @override
  void dispose() {
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Set<_Problem> _validate() => {
    if (_new.text.length < ChangePassword.minLength) _Problem.tooShort,
    if (_new.text != _confirm.text) _Problem.mismatch,
  };

  void _generate() {
    final password = SetPasswordDialog.generate(_random);
    setState(() {
      _new.text = password;
      _confirm.text = password;
      _generated = true;
      _problems = const {};
    });
  }

  Future<void> _copy() async {
    final strings = AppStrings.of(context);
    await Clipboard.setData(ClipboardData(text: _new.text));
    if (mounted) showAppToast(context, strings.passwordCopied, tone: AppTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    final name = widget.teacher.fullName;

    return SubmitDialog<void>(
      title: strings.setTeacherPasswordTitle(name),
      width: 460,
      prepare: () {
        setState(() => _problems = _validate());
        if (_problems.isNotEmpty) return null;
        return () => widget.setPassword(SetTeacherPasswordParams(widget.teacher.id, _new.text));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessage(text: strings.setTeacherPasswordHint(name), tone: AppTone.info),
          gap,
          // Rebuilt in clear once generated: the key changes so the field starts unhidden.
          AppTextField(
            key: ValueKey('new-$_generated'),
            label: strings.newPassword,
            controller: _new,
            obscure: !_generated,
            autofocus: true,
            errorText: _problems.contains(_Problem.tooShort) ? strings.validationPassword : null,
          ),
          gap,
          AppTextField(
            key: ValueKey('confirm-$_generated'),
            label: strings.confirmPassword,
            controller: _confirm,
            obscure: !_generated,
            errorText: _problems.contains(_Problem.mismatch) ? strings.passwordsDoNotMatch : null,
          ),
          gap,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: strings.generatePassword,
                icon: AppIcons.refresh,
                variant: AppButtonVariant.tinted,
                size: AppButtonSize.small,
                onPressed: _generate,
              ),
              if (_generated)
                AppButton(
                  label: strings.copyPassword,
                  icon: AppIcons.copy,
                  variant: AppButtonVariant.plain,
                  size: AppButtonSize.small,
                  onPressed: _copy,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
