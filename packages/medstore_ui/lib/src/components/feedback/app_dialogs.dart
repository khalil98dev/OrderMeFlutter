import 'package:flutter/cupertino.dart';

import '../../l10n/app_strings.dart';

/// Asks the user to confirm an action. Resolves to `true` only when they confirm.
///
/// ```dart
/// final confirmed = await showAppConfirmDialog(
///   context,
///   title: strings.cancelOrderTitle,
///   message: strings.cancelOrderMessage,
///   confirmLabel: strings.cancelOrder,
///   destructive: true,
/// );
/// if (confirmed) await cubit.cancel(order.id);
/// ```
///
/// Tapping outside or pressing Escape counts as "no". Cancel is the default (bold) action, so a
/// hurried Enter never deletes anything.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final strings = AppStrings.of(context);
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? strings.cancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
