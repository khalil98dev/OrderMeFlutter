import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../../schools/domain/school.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';

/// Creates a teacher with their sign-in account (no [teacher]) or edits a teacher's profile.
class TeacherFormDialog extends StatefulWidget {
  const TeacherFormDialog({super.key, required this.save, required this.schools, this.teacher});

  final SaveTeacher save;
  final List<School> schools;
  final Teacher? teacher;

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  late final TeacherDraft _initial = widget.teacher == null
      ? const TeacherDraft(fullName: '')
      : TeacherDraft.of(widget.teacher!);
  late final _fullName = TextEditingController(text: _initial.fullName);
  late final _phone = TextEditingController(text: _initial.phone);
  late final _subject = TextEditingController(text: _initial.subject);
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  late String? _schoolId = _initial.schoolId;
  late PaymentTerms? _terms = _initial.paymentTerms;
  Set<TeacherField> _problems = const {};

  bool get _isNew => widget.teacher == null;

  @override
  void dispose() {
    for (final controller in [_fullName, _phone, _subject, _userName, _password, _email]) {
      controller.dispose();
    }
    super.dispose();
  }

  TeacherDraft get _draft => TeacherDraft(
    fullName: _fullName.text,
    phone: _phone.text,
    subject: _subject.text,
    userName: _userName.text,
    password: _password.text,
    email: _email.text,
    schoolId: _schoolId,
    paymentTerms: _terms,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    const gap = SizedBox(height: AppSpacing.md);
    const columnGap = SizedBox(width: AppSpacing.md);
    String? error(TeacherField field, String text) => _problems.contains(field) ? text : null;

    return SubmitDialog<void>(
      title: _isNew ? strings.newTeacher : strings.editTeacher,
      width: 620,
      prepare: () {
        final draft = _draft;
        setState(() => _problems = draft.validate(isNew: _isNew));
        if (_problems.isNotEmpty) return null;
        return () => widget.save(SaveTeacherParams(draft, teacherId: widget.teacher?.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: strings.fieldFullName,
            controller: _fullName,
            isRequired: true,
            autofocus: true,
            errorText: error(TeacherField.fullName, strings.fieldRequired),
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: strings.fieldPhone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                ),
              ),
              columnGap,
              Expanded(
                child: AppTextField(label: strings.fieldSubject, controller: _subject),
              ),
            ],
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppSelectField<String>(
                  label: strings.fieldSchool,
                  options: {for (final school in widget.schools) school.id: school.name},
                  value: _schoolId,
                  allowNone: true,
                  noneLabel: strings.none,
                  onChanged: (value) => setState(() => _schoolId = value),
                ),
              ),
              columnGap,
              Expanded(
                child: AppSelectField<PaymentTerms>(
                  label: strings.fieldPaymentTerms,
                  options: paymentTermsOptions(strings),
                  value: _terms,
                  // A new teacher may take the billing settings' default.
                  allowNone: _isNew,
                  noneLabel: strings.paymentTermsDefault,
                  onChanged: (value) => setState(() => _terms = value ?? (_isNew ? null : _terms)),
                ),
              ),
            ],
          ),
          if (_isNew) ...[
            const SizedBox(height: AppSpacing.lg),
            AppFieldLabel(strings.signInAccount),
            Text(
              strings.signInAccountHint,
              style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: strings.userName,
                    controller: _userName,
                    isRequired: true,
                    errorText: error(TeacherField.userName, strings.fieldRequired),
                  ),
                ),
                columnGap,
                Expanded(
                  child: AppTextField(
                    label: strings.password,
                    controller: _password,
                    obscure: true,
                    isRequired: true,
                    errorText: error(TeacherField.password, strings.validationPassword),
                  ),
                ),
              ],
            ),
            gap,
            AppTextField(
              label: strings.fieldEmail,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ],
      ),
    );
  }
}
