import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/di/injection.dart';

/// Desktop sign-in: the form in a card centered on the canvas, the language switch in the corner.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: const AppCard(padding: EdgeInsets.all(AppSpacing.xl), child: _LoginFormBinding()),
                  ),
                ),
              ),
              const PositionedDirectional(top: AppSpacing.md, end: AppSpacing.md, child: _LanguageBinding()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connects the form to [LoginCubit], and hands a successful sign-in to [AuthCubit].
class _LoginFormBinding extends StatelessWidget {
  const _LoginFormBinding();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) => current.status == LoginStatus.succeeded,
      listener: (context, state) => context.read<AuthCubit>().signedIn(state.user!),
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting || previous.failure != current.failure,
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        return LoginForm(
          subtitle: AppStrings.of(context).loginSubtitleAdmin,
          isSubmitting: state.isSubmitting,
          failure: state.failure,
          onSubmit: (userName, password) => cubit.submit(userName: userName, password: password),
          onEdited: cubit.edited,
        );
      },
    );
  }
}

class _LanguageBinding extends StatelessWidget {
  const _LanguageBinding();

  @override
  Widget build(BuildContext context) {
    return LanguageSwitch(
      current: Localizations.localeOf(context),
      onChanged: (locale) => context.read<LocaleCubit>().choose(locale),
    );
  }
}
