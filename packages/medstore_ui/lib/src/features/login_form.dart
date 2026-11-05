import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';

import '../components/buttons/app_button.dart';
import '../components/display/app_logo.dart';
import '../components/feedback/app_message.dart';
import '../components/inputs/app_text_field.dart';
import '../failure_text.dart';
import '../l10n/app_strings.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_metrics.dart';
import '../tokens/app_typography.dart';

/// The sign-in form both apps use. Only draws and validates: the app's login page connects it to
/// `LoginCubit` and lays it out (a centered card on desktop, full screen on mobile).
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.subtitle,
    required this.isSubmitting,
    required this.onSubmit,
    this.failure,
    this.onEdited,
  });

  final String subtitle;
  final bool isSubmitting;
  final Failure? failure;
  final void Function(String userName, String password) onSubmit;
  final VoidCallback? onEdited;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _userName = TextEditingController();
  final _password = TextEditingController();
  var _showRequired = false;

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_userName.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _showRequired = true);
      return;
    }
    widget.onSubmit(_userName.text, _password.text);
  }

  void _edited(String _) {
    if (_showRequired) setState(() => _showRequired = false);
    widget.onEdited?.call();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final failure = widget.failure;
    final required = strings.fieldRequired;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: AppLogo(size: 88)),
          const SizedBox(height: AppSpacing.md),
          Text(
            strings.loginTitle,
            textAlign: TextAlign.center,
            style: AppTypography.title1.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: strings.userName,
            controller: _userName,
            enabled: !widget.isSubmitting,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            errorText: _showRequired && _userName.text.trim().isEmpty ? required : null,
            onChanged: _edited,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: strings.password,
            controller: _password,
            obscure: true,
            enabled: !widget.isSubmitting,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            errorText: _showRequired && _password.text.isEmpty ? required : null,
            onChanged: _edited,
            onSubmitted: (_) => _submit(),
          ),
          if (failure != null && failure is! CancelledFailure) ...[
            const SizedBox(height: AppSpacing.md),
            AppMessage(
              // At sign-in a 401 means a wrong user name or password, not an expired session.
              text: failure is UnauthorizedFailure ? strings.wrongCredentials : failureText(strings, failure),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: strings.signIn, onPressed: _submit, isLoading: widget.isSubmitting, expand: true),
        ],
      ),
    );
  }
}
