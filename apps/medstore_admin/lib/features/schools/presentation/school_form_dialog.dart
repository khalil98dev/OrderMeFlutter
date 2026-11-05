import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/school.dart';
import '../domain/school_repository.dart';

/// Creates a school (no [school]) or edits one. Closes saved or cancelled.
class SchoolFormDialog extends StatefulWidget {
  const SchoolFormDialog({super.key, required this.save, this.school});

  final SaveSchool save;
  final School? school;

  @override
  State<SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<SchoolFormDialog> {
  late final SchoolDraft _initial = widget.school == null
      ? const SchoolDraft(name: '', wilayaText: '')
      : SchoolDraft.of(widget.school!);
  late final _name = TextEditingController(text: _initial.name);
  late final _wilaya = TextEditingController(text: _initial.wilayaText);
  late final _city = TextEditingController(text: _initial.city);
  late SchoolLevel _level = _initial.level;
  late SchoolType _type = _initial.type;
  Set<SchoolField> _problems = const {};

  @override
  void dispose() {
    _name.dispose();
    _wilaya.dispose();
    _city.dispose();
    super.dispose();
  }

  SchoolDraft get _draft =>
      SchoolDraft(name: _name.text, wilayaText: _wilaya.text, city: _city.text, level: _level, type: _type);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    return SubmitDialog<void>(
      title: widget.school == null ? strings.newSchool : strings.editSchool,
      prepare: () {
        final draft = _draft;
        setState(() => _problems = draft.validate());
        if (_problems.isNotEmpty) return null;
        return () => widget.save(SaveSchoolParams(draft, schoolId: widget.school?.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: strings.fieldName,
            controller: _name,
            isRequired: true,
            autofocus: true,
            errorText: _problems.contains(SchoolField.name) ? strings.fieldRequired : null,
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: AppTextField(
                  label: strings.fieldWilaya,
                  controller: _wilaya,
                  digitsOnly: true,
                  isRequired: true,
                  placeholder: '16',
                  errorText: _problems.contains(SchoolField.wilaya) ? strings.wilayaInvalid : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(label: strings.fieldCity, controller: _city),
              ),
            ],
          ),
          gap,
          Row(
            children: [
              Expanded(
                child: AppSelectField<SchoolLevel>(
                  label: strings.fieldSchoolLevel,
                  options: {for (final level in SchoolLevel.values) level: schoolLevelText(strings, level)},
                  value: _level,
                  onChanged: (value) => setState(() => _level = value ?? _level),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppSelectField<SchoolType>(
                  label: strings.fieldSchoolType,
                  options: {for (final type in SchoolType.values) type: schoolTypeText(strings, type)},
                  value: _type,
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
