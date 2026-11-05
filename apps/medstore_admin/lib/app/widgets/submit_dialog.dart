import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../forms/form_values.dart';

/// An [AppDialog] around a small form that saves through the API: the save button spins while the
/// request runs, a refusal shows above the form, and success closes the dialog with the answer.
///
/// ```dart
/// final saved = await showAppDialog<School>(context, builder: (_) => SubmitDialog<School>(
///   title: strings.newSchool,
///   prepare: () => draft.validate().isEmpty ? () => saveSchool(draft) : null,
///   child: fields,
/// ));
/// ```
///
/// [prepare] runs the form's own checks: it returns the action to send, or null to stay open (the form
/// then marks its wrong fields itself).
class SubmitDialog<T> extends StatelessWidget {
  const SubmitDialog({
    super.key,
    required this.title,
    required this.prepare,
    required this.child,
    this.submitLabel,
    this.destructive = false,
    this.width = 520,
  });

  final String title;
  final Future<Result<T>> Function()? Function() prepare;
  final Widget child;

  /// Defaults to "Save".
  final String? submitLabel;
  final bool destructive;
  final double width;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubmitCubit<T>(),
      child: BlocConsumer<SubmitCubit<T>, SubmitState<T>>(
        listenWhen: (previous, current) => current.status == SubmitStatus.done,
        listener: (context, state) => Navigator.of(context).pop(_Saved<T>(state.value as T)),
        builder: (context, state) {
          final strings = AppStrings.of(context);
          final failure = state.failure;
          return AppDialog(
            title: title,
            width: width,
            actions: [
              AppButton(
                label: strings.cancel,
                variant: AppButtonVariant.plain,
                onPressed: state.isBusy ? null : () => Navigator.of(context).pop(),
              ),
              AppButton(
                label: submitLabel ?? strings.save,
                variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.filled,
                isLoading: state.isBusy,
                onPressed: () {
                  final action = prepare();
                  if (action != null) context.read<SubmitCubit<T>>().run(action);
                },
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (failure != null) ...[
                  AppMessage(text: problemText(strings, failure)),
                  const SizedBox(height: AppSpacing.md),
                ],
                child,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// What a [SubmitDialog] closes with, so "saved with a null answer" differs from "cancelled".
final class _Saved<T> {
  const _Saved(this.value);

  final T value;
}

/// Opens a [SubmitDialog] built by [builder]. Resolves to `(saved: true, value)` after a save,
/// `(saved: false, null)` when cancelled.
Future<({bool saved, T? value})> showSubmitDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) async {
  final result = await showAppDialog<Object?>(context, builder: builder);
  return switch (result) {
    _Saved<T>(:final value) => (saved: true, value: value),
    _ => (saved: false, value: null),
  };
}
