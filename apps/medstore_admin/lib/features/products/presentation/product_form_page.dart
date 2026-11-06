import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/shell/admin_page.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../domain/product_draft.dart';
import 'cover_editor.dart';
import 'product_form_cubit.dart';
import 'teacher_picker.dart';

/// Create a product (no [product]) or edit one. Comes back with `true` when saved.
///
/// The page keeps what is being typed; [ProductFormCubit] checks it and saves it.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final ProductDraft _initial = widget.product == null
      ? const ProductDraft(name: '')
      : ProductDraft.of(widget.product!);

  late final _name = TextEditingController(text: _initial.name);
  late final _code = TextEditingController(text: _initial.code);
  late final _description = TextEditingController(text: _initial.description);
  late final _subject = TextEditingController(text: _initial.subject);
  late final _level = TextEditingController(text: _initial.level);
  late final _pageCount = TextEditingController(text: _initial.pageCountText);
  late final _price = TextEditingController(text: _initial.priceText);

  TeacherSummary? _teacher;
  late ProductType _type = _initial.type;
  late bool _isAvailable = _initial.isAvailable;
  CoverChange _cover = const KeepCover();

  bool get _isNew => widget.product == null;

  @override
  void dispose() {
    for (final controller in [_name, _code, _description, _subject, _level, _pageCount, _price]) {
      controller.dispose();
    }
    super.dispose();
  }

  ProductDraft _draft() => ProductDraft(
    teacherId: _isNew ? _teacher?.id : widget.product!.clientId,
    name: _name.text,
    code: _code.text,
    description: _description.text,
    subject: _subject.text,
    level: _level.text,
    type: _type,
    pageCountText: _pageCount.text,
    priceText: _price.text,
    isAvailable: _isAvailable,
  );

  Future<void> _pickTeacher() async {
    final teacher = await showTeacherPicker(context, search: context.read<SearchTeachers>());
    if (teacher != null) setState(() => _teacher = teacher);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<ProductFormCubit>();

    return BlocConsumer<ProductFormCubit, ProductFormState>(
      listenWhen: (previous, current) => current.status == ProductFormStatus.saved,
      listener: (context, state) => context.pop(true),
      builder: (context, state) {
        String? errorOf(ProductField field) => switch (state.problems[field]) {
          final problem? => _problemText(strings, field, problem),
          null => null,
        };

        return AdminPage(
          title: _isNew ? strings.newProduct : strings.editProduct,
          subtitle: widget.product?.name,
          actions: [
            AppButton(
              label: strings.cancel,
              variant: AppButtonVariant.plain,
              onPressed: state.isSaving ? null : () => context.pop(false),
            ),
            AppButton(
              label: strings.save,
              icon: AppIcons.check,
              isLoading: state.isSaving,
              onPressed: () => cubit.save(_draft(), _cover),
            ),
          ],
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_generalMessage(strings, state) case final message?) ...[
                        AppMessage(text: message),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppCard(child: _fields(strings, errorOf)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                SizedBox(
                  width: 260,
                  child: CoverEditor(
                    current: widget.product == null
                        ? null
                        : context.read<ProductImages>().cover(widget.product!),
                    change: _cover,
                    error: errorOf(ProductField.cover),
                    onChanged: (change) => setState(() => _cover = change),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fields(AppStrings strings, String? Function(ProductField) errorOf) {
    const gap = SizedBox(height: AppSpacing.md);
    const columnGap = SizedBox(width: AppSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isNew)
          TeacherField(teacher: _teacher, error: errorOf(ProductField.teacher), onTap: _pickTeacher)
        else
          _OwnerLine(name: widget.product!.clientName ?? ''),
        gap,
        AppTextField(
          label: strings.fieldName,
          controller: _name,
          isRequired: true,
          errorText: errorOf(ProductField.name),
        ),
        gap,
        Text(strings.fieldType, style: _labelStyle(context)),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSegmentedControl<ProductType>(
            segments: {for (final type in ProductType.values) type: productTypeText(strings, type)},
            selected: _type,
            onChanged: (type) => setState(() => _type = type),
          ),
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: strings.fieldCode,
                controller: _code,
                errorText: errorOf(ProductField.code),
              ),
            ),
            columnGap,
            Expanded(
              child: AppTextField(
                label: strings.fieldSubject,
                controller: _subject,
                errorText: errorOf(ProductField.subject),
              ),
            ),
            columnGap,
            Expanded(
              child: AppTextField(
                label: strings.fieldLevel,
                controller: _level,
                placeholder: '3AS',
                errorText: errorOf(ProductField.level),
              ),
            ),
          ],
        ),
        gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: strings.fieldPrice,
                controller: _price,
                isRequired: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: errorOf(ProductField.price),
              ),
            ),
            columnGap,
            Expanded(
              child: AppTextField(
                label: strings.fieldPageCount,
                controller: _pageCount,
                digitsOnly: true,
                errorText: errorOf(ProductField.pageCount),
              ),
            ),
          ],
        ),
        gap,
        AppTextField(
          label: strings.fieldDescription,
          controller: _description,
          maxLines: 4,
          errorText: errorOf(ProductField.description),
        ),
        if (!_isNew) ...[
          gap,
          _AvailabilitySwitch(
            value: _isAvailable,
            onChanged: (value) => setState(() => _isAvailable = value),
          ),
        ],
      ],
    );
  }

  static TextStyle _labelStyle(BuildContext context) => AppTypography.footnote.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary.resolveFrom(context),
  );

  /// A message above the form when saving failed for a reason that is not one field.
  static String? _generalMessage(AppStrings strings, ProductFormState state) {
    final failure = state.failure;
    if (failure == null) return null;
    if (state.coverFailed) return strings.savedButCoverFailed;
    if (state.problems.isNotEmpty) return null; // the marked fields say it
    return failureText(strings, failure);
  }

  static String _problemText(AppStrings strings, ProductField field, FieldProblem problem) =>
      switch (problem) {
        FieldProblem.required => strings.fieldRequired,
        FieldProblem.tooLong => strings.tooLong(ProductDraft.maxLengths[field] ?? 0),
        FieldProblem.priceInvalid => strings.priceInvalid,
        FieldProblem.pageCountInvalid => strings.pageCountInvalid,
        FieldProblem.codeTaken => strings.codeTaken,
        FieldProblem.teacherUnavailable => strings.teacherUnavailable,
        FieldProblem.imageTooLarge => strings.imageTooLarge,
        FieldProblem.imageTypeInvalid => strings.imageTypeInvalid,
      };
}

/// On an existing product: whose it is, and that it cannot change.
class _OwnerLine extends StatelessWidget {
  const _OwnerLine({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      children: [
        AppAvatar(name: name),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
              ),
              Text(
                strings.ownerCannotChange,
                style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      children: [
        CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.signal.resolveFrom(context),
          onChanged: onChanged,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.fieldAvailable,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
              ),
              Text(
                strings.fieldAvailableHint,
                style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
