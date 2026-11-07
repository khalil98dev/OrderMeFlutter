import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../teachers/domain/teacher_directory.dart';

/// The "Teacher" field of a new product: shows the chosen teacher, or a button to choose one.
class TeacherField extends StatelessWidget {
  const TeacherField({super.key, required this.teacher, required this.onTap, this.error});

  final TeacherSummary? teacher;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final teacher = this.teacher;
    final error = this.error;
    final border = error == null ? AppColors.border : AppColors.destructive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${strings.fieldTeacher} *',
          style: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.resolveFrom(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadii.smRadius,
            border: Border.all(color: border.resolveFrom(context)),
          ),
          child: AppListTile(
            leading: teacher == null
                ? Icon(AppIcons.addPerson, color: AppColors.accent.resolveFrom(context))
                : AppAvatar(name: teacher.fullName, size: 32),
            title: teacher?.fullName ?? strings.chooseTeacher,
            subtitle: teacher?.schoolName,
            onTap: onTap,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: AppTypography.footnote.copyWith(color: AppColors.destructive.resolveFrom(context)),
          ),
        ],
      ],
    );
  }
}

/// A dialog listing active teachers with a search box. Resolves to the chosen one, or null.
Future<TeacherSummary?> showTeacherPicker(BuildContext context, {required SearchTeachers search}) {
  return showCupertinoDialog<TeacherSummary>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TeacherPickerDialog(search: search),
  );
}

class _TeacherPickerDialog extends StatefulWidget {
  const _TeacherPickerDialog({required this.search});

  final SearchTeachers search;

  @override
  State<_TeacherPickerDialog> createState() => _TeacherPickerDialogState();
}

class _TeacherPickerDialogState extends State<_TeacherPickerDialog> {
  List<TeacherSummary> _teachers = const [];
  Failure? _failure;
  var _isLoading = true;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _search('');
  }

  Future<void> _search(String query) async {
    _query = query;
    setState(() => _isLoading = true);
    final result = await widget.search(query);
    // Typing is faster than the network: ignore answers to a search the user already changed.
    if (!mounted || query != _query) return;
    setState(() {
      _isLoading = false;
      switch (result) {
        case Ok(:final value):
          _teachers = value;
          _failure = null;
        case Err(:final failure):
          _failure = failure;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: SizedBox(
        width: 440,
        height: 520,
        child: CupertinoPopupSurface(
          child: ColoredBox(
            color: AppColors.surface.resolveFrom(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.chooseTeacher,
                        style: AppTypography.title3.copyWith(
                          color: AppColors.textPrimary.resolveFrom(context),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppSearchField(autofocus: true, onChanged: _search),
                    ],
                  ),
                ),
                Expanded(
                  child: AppLoadView(
                    isLoading: _isLoading,
                    hasData: _teachers.isNotEmpty,
                    failure: _failure,
                    onRetry: () => _search(_query),
                    empty: AppEmptyState(icon: AppIcons.teachers, title: strings.noResultsTitle),
                    builder: (context) => ListView.builder(
                      itemCount: _teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _teachers[index];
                        return AppListTile(
                          leading: AppAvatar(name: teacher.fullName),
                          title: teacher.fullName,
                          subtitle: [teacher.schoolName, teacher.subject].whereType<String>().join(' · '),
                          showChevron: false,
                          onTap: () => Navigator.of(context).pop(teacher),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: AppButton(
                    label: strings.cancel,
                    variant: AppButtonVariant.plain,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
