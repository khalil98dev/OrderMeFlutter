import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../schools/domain/school.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';
import 'set_password_dialog.dart';
import 'statement_view.dart';
import 'teacher_form_dialog.dart';

/// One teacher: profile, links to their wallet, debts and invoices, and their statement.
///
/// Expects a `LoadCubit<Teacher>`, a `LoadCubit<List<School>>`, the statement's providers (see
/// [StatementView]), [SaveTeacher], [SetTeacherPassword] and [DeactivateTeacher] above it.
class TeacherDetailPage extends StatelessWidget {
  const TeacherDetailPage({super.key, required this.teacherId});

  final String teacherId;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Teacher>>();
    final state = context.watch<LoadCubit<Teacher>>().state;
    final teacher = state.data;
    final today = DateTime.now();

    return AdminPage(
      title: teacher?.fullName ?? strings.navTeachers,
      subtitle: teacher?.userName,
      onBack: () => context.pop(),
      actions: [
        if (teacher != null) ...[
          AppButton(
            label: strings.navWallet,
            icon: AppIcons.wallet,
            variant: AppButtonVariant.plain,
            onPressed: () => context.go('/wallet/${teacher.id}'),
          ),
          AppButton(
            label: strings.navDebts,
            icon: AppIcons.warning,
            variant: AppButtonVariant.plain,
            onPressed: () => context.go('/debts/${teacher.id}'),
          ),
          AppButton(
            label: strings.edit,
            icon: AppIcons.edit,
            variant: AppButtonVariant.tinted,
            onPressed: () => _edit(context, teacher),
          ),
          // A deactivated account cannot sign in whatever its password: no reset for it.
          if (teacher.isActive)
            AppButton(
              label: strings.setTeacherPassword,
              icon: AppIcons.password,
              variant: AppButtonVariant.plain,
              onPressed: () => _setPassword(context, teacher),
            ),
          if (teacher.isActive)
            AppButton(
              label: strings.deactivate,
              variant: AppButtonVariant.destructive,
              onPressed: () => _deactivate(context, teacher),
            ),
        ],
      ],
      child: AppLoadView(
        isLoading: state.isLoading || (!state.hasData && state.failure == null),
        hasData: teacher != null,
        failure: state.failure,
        onRetry: cubit.load,
        empty: const SizedBox.shrink(),
        builder: (context) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Profile(teacher: teacher!),
              const SizedBox(height: AppSpacing.xl),
              StatementView(
                clientId: teacherId,
                initialFrom: DateTime(today.year),
                initialTo: DateTime(today.year, today.month, today.day),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _edit(BuildContext context, Teacher teacher) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Teacher>>();
    final save = context.read<SaveTeacher>();
    final schools = context.read<LoadCubit<List<School>>>().state.data ?? const <School>[];
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => TeacherFormDialog(save: save, schools: schools, teacher: teacher),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.teacherSaved, tone: AppTone.success);
    await cubit.load();
  }

  static Future<void> _setPassword(BuildContext context, Teacher teacher) async {
    final strings = AppStrings.of(context);
    final setPassword = context.read<SetTeacherPassword>();
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => SetPasswordDialog(teacher: teacher, setPassword: setPassword),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.teacherPasswordSet, tone: AppTone.success);
  }

  static Future<void> _deactivate(BuildContext context, Teacher teacher) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<Teacher>>();
    final deactivate = context.read<DeactivateTeacher>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: strings.deactivateTeacherTitle(teacher.fullName),
      message: strings.deactivateTeacherMessage,
      confirmLabel: strings.deactivate,
      destructive: true,
    );
    if (!confirmed) return;
    final result = await deactivate(teacher.id);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showAppToast(context, strings.teacherDeactivated, tone: AppTone.success);
        await cubit.load();
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final terms = teacher.paymentTerms;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: teacher.fullName, size: 56),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                AppInfoRow(label: strings.fieldPhone, value: teacher.phone),
                AppInfoRow(label: strings.fieldSubject, value: teacher.subject),
                AppInfoRow(label: strings.fieldSchool, value: teacher.schoolName),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              children: [
                AppInfoRow(
                  label: strings.fieldPaymentTerms,
                  value: terms == null ? null : paymentTermsText(strings, terms),
                ),
                AppInfoRow(
                  label: strings.fieldStatus,
                  child: AppBadge(
                    label: teacher.isActive ? strings.active : strings.inactive,
                    tone: teacher.isActive ? AppTone.success : AppTone.neutral,
                  ),
                ),
                AppInfoRow(
                  label: strings.colDate,
                  value: AppDateFormat.day(teacher.createdAt.toLocal(), locale),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
