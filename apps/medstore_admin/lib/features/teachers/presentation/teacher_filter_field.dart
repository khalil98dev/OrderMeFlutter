import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../products/presentation/teacher_picker.dart';
import '../domain/teacher_directory.dart';

/// "Teacher: all / Amina Benali ×": narrows a list (orders, invoices, products) to one teacher.
///
/// Reports `(id, name)` of the chosen teacher, or null when cleared.
class TeacherFilterField extends StatelessWidget {
  const TeacherFilterField({
    super.key,
    required this.search,
    required this.teacherName,
    required this.onChanged,
    this.label,
    this.allowNone = true,
    this.errorText,
  });

  final SearchTeachers search;

  /// The chosen teacher's name; null shows "All teachers".
  final String? teacherName;
  final ValueChanged<(String, String)?> onChanged;
  final String? label;

  /// Whether the field can be emptied (a filter) or must keep a teacher (a form).
  final bool allowNone;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final name = teacherName;
    return AppFieldBox(
      label: label ?? strings.fieldTeacher,
      value: name,
      placeholder: allowNone ? strings.allTeachers : strings.chooseTeacher,
      icon: AppIcons.person,
      errorText: errorText,
      isRequired: !allowNone,
      onTap: () async {
        final teacher = await showTeacherPicker(context, search: search);
        if (teacher != null) onChanged((teacher.id, teacher.fullName));
      },
      trailing: allowNone && name != null
          ? AppIconButton(icon: AppIcons.cancelled, label: strings.clear, onPressed: () => onChanged(null))
          : null,
    );
  }
}
