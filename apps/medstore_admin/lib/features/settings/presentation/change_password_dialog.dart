import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/widgets/submit_dialog.dart';

enum _Problem { currentRequired, tooShort, mismatch }

/// Changes the signed-in user's password. Other devices are signed out; this one stays signed in.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, required this.changePassword});

  final ChangePassword changePassword;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  Set<_Problem> _problems = const {};

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Set<_Problem> _validate() => {
    if (_current.text.isEmpty) _Problem.currentRequired,
    if (_new.text.length < ChangePassword.minLength) _Problem.tooShort,
    if (_new.text != _confirm.text) _Problem.mismatch,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    return SubmitDialog<void>(
      title: strings.changePassword,
      width: 440,
      prepare: () {
        setState(() => _problems = _validate());
        if (_problems.isNotEmpty) return null;
        return () => widget.changePassword(
          ChangePasswordParams(currentPassword: _current.text, newPassword: _new.text),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessage(text: strings.changePasswordHint, tone: AppTone.info),
          gap,
          AppTextField(
            label: strings.currentPassword,
            controller: _current,
            obscure: true,
            autofocus: true,
            errorText: _problems.contains(_Problem.currentRequired) ? strings.fieldRequired : null,
          ),
          gap,
          AppTextField(
            label: strings.newPassword,
            controller: _new,
            obscure: true,
            errorText: _problems.contains(_Problem.tooShort) ? strings.validationPassword : null,
          ),
          gap,
          AppTextField(
            label: strings.confirmPassword,
            controller: _confirm,
            obscure: true,
            errorText: _problems.contains(_Problem.mismatch) ? strings.passwordsDoNotMatch : null,
          ),
        ],
      ),
    );
  }
}
