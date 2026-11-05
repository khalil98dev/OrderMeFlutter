import 'package:flutter/cupertino.dart';

import '../../tokens/app_colors.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';

/// Opens [builder]'s dialog (usually an [AppDialog]) over the page. Tapping outside or pressing
/// Escape closes it with `null`.
///
/// ```dart
/// final saved = await showAppDialog<bool>(context, builder: (_) => const DepositDialog());
/// ```
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) =>
    showCupertinoDialog<T>(context: context, barrierDismissible: true, builder: builder);

/// A desktop dialog with a title, any content, and buttons at the bottom: a small form (a deposit,
/// a school), a picker, a detail that does not deserve a page.
///
/// ```dart
/// AppDialog(
///   title: strings.newDeposit,
///   actions: [
///     AppButton(label: strings.cancel, variant: AppButtonVariant.plain, onPressed: () => Navigator.pop(context)),
///     AppButton(label: strings.save, isLoading: saving, onPressed: save),
///   ],
///   child: Column(children: [AppTextField(label: strings.fieldAmount, controller: amount)]),
/// )
/// ```
///
/// For a yes/no question use `showAppConfirmDialog`; for one line of text use `showAppTextPrompt`.
/// The content scrolls when the window is too short.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.width = 480,
  });

  final String title;
  final Widget child;

  /// Buttons on the end side, the main one last.
  final List<Widget> actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: ClipRRect(
            borderRadius: AppRadii.lgRadius,
            child: ColoredBox(
              color: AppColors.surface.resolveFrom(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AppTypography.title3.copyWith(
                          color: AppColors.textPrimary.resolveFrom(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Flexible(child: SingleChildScrollView(child: child)),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final (index, action) in actions.indexed) ...[
                            if (index > 0) const SizedBox(width: AppSpacing.xs),
                            action,
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
