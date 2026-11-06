import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../failure_text.dart';
import '../../l10n/app_strings.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_tone.dart';
import '../buttons/app_button.dart';
import 'app_empty_state.dart';

/// A full-area error for a screen that could not load, with a "Try again" button.
///
/// ```dart
/// AppErrorState(failure: state.failure!, onRetry: cubit.load)
/// ```
///
/// The icon follows the failure: no connection shows a crossed-out wifi, the rest a warning sign.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.failure, this.onRetry});

  final Failure failure;

  /// Null hides the button (for failures retrying cannot fix, like "not allowed").
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final offline = failure is NetworkFailure;
    return AppEmptyState(
      icon: offline ? AppIcons.offline : AppIcons.warning,
      tone: offline ? AppTone.warning : AppTone.danger,
      title: strings.errorTitle,
      message: failureText(strings, failure),
      action: onRetry == null
          ? null
          : AppButton(
              label: strings.retry,
              icon: AppIcons.retry,
              variant: AppButtonVariant.tinted,
              onPressed: onRetry,
            ),
    );
  }
}
