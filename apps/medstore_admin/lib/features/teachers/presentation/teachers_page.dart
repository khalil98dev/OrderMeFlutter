import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/paged_table.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../schools/domain/school.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';
import 'teacher_form_dialog.dart';

typedef TeachersCubit = PagedListCubit<Teacher, TeacherFilter>;

/// Every teacher: search, school and status filters, create; a row opens the teacher's page.
///
/// Expects a [TeachersCubit], a `LoadCubit<List<School>>` and [SaveTeacher] above it.
class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<TeachersCubit>();
    final total = context.select<TeachersCubit, int>((cubit) => cubit.state.totalCount);
    final filter = context.select<TeachersCubit, TeacherFilter>((cubit) => cubit.state.filter);
    final schools = context.select<LoadCubit<List<School>>, List<School>>(
      (cubit) => cubit.state.data ?? const [],
    );

    return AdminPage(
      title: strings.navTeachers,
      subtitle: total > 0 ? strings.teachersCount(total) : null,
      actions: [
        AppButton(label: strings.newTeacher, icon: AppIcons.add, onPressed: () => _create(context, schools)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppSearchField(
                  placeholder: strings.searchTeachers,
                  onChanged: (text) => cubit.setFilter(filter.copyWith(search: text)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 240,
                child: AppSelectField<String>(
                  label: strings.fieldSchool,
                  options: {for (final school in schools) school.id: school.name},
                  value: filter.schoolId,
                  allowNone: true,
                  onChanged: (id) => cubit.setFilter(filter.copyWith(schoolId: () => id)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppSegmentedControl<_Status>(
                segments: {
                  _Status.active: strings.active,
                  _Status.inactive: strings.inactive,
                  _Status.all: strings.filterAll,
                },
                selected: _Status.of(filter.isActive),
                onChanged: (status) => cubit.setFilter(filter.copyWith(isActive: () => status.isActive)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: PagedTable<Teacher, TeacherFilter>(
              columns: [
                AppTableColumn(strings.fieldFullName, flex: 3),
                AppTableColumn(strings.colPhone, width: 140),
                AppTableColumn(strings.colSchool, flex: 2),
                AppTableColumn(strings.fieldPaymentTerms, width: 130),
                AppTableColumn(strings.fieldStatus, width: 100),
              ],
              onTap: (teacher) => context.push('/teachers/${teacher.id}'),
              empty: AppEmptyState(
                icon: AppIcons.teachers,
                title: strings.noTeachersTitle,
                message: strings.noTeachersMessage,
              ),
              cells: (context, teacher) => [
                Row(
                  children: [
                    AppAvatar(name: teacher.fullName, size: 32),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(teacher.fullName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                Text(teacher.phone ?? '—'),
                Text(teacher.schoolName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(teacher.paymentTerms == null ? '—' : paymentTermsText(strings, teacher.paymentTerms!)),
                AppBadge(
                  label: teacher.isActive ? strings.active : strings.inactive,
                  tone: teacher.isActive ? AppTone.success : AppTone.neutral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _create(BuildContext context, List<School> schools) async {
    final strings = AppStrings.of(context);
    final cubit = context.read<TeachersCubit>();
    final save = context.read<SaveTeacher>();
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => TeacherFormDialog(save: save, schools: schools),
    );
    if (!result.saved || !context.mounted) return;
    showAppToast(context, strings.teacherSaved, tone: AppTone.success);
    await cubit.load();
  }
}

enum _Status {
  active(true),
  inactive(false),
  all(null);

  const _Status(this.isActive);

  final bool? isActive;

  static _Status of(bool? isActive) => values.firstWhere((status) => status.isActive == isActive);
}
