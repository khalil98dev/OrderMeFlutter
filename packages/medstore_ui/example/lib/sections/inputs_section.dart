import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

enum _OrderFilter { open, ready, all }

class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  var _query = '';
  var _filter = _OrderFilter.open;
  var _quantity = 30;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GallerySection(
      title: tr(context, 'Saisie', 'الإدخال'),
      components: 'AppTextField · AppSearchField · AppSegmentedControl · AppQuantityStepper · LanguageSwitch',
      children: [
        Demo(
          label: 'AppTextField',
          child: Column(
            children: [
              AppTextField(label: strings.userName, placeholder: 'prof.amina'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(label: strings.password, obscure: true, errorText: strings.fieldRequired),
            ],
          ),
        ),
        Demo(
          label: 'AppSearchField (300 ms)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSearchField(onChanged: (query) => setState(() => _query = query)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'onChanged: "$_query"',
                style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
              ),
            ],
          ),
        ),
        Demo(
          label: 'AppSegmentedControl · AppQuantityStepper',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSegmentedControl<_OrderFilter>(
                segments: {
                  _OrderFilter.open: tr(context, 'En cours', 'قيد الإنجاز'),
                  _OrderFilter.ready: tr(context, 'Prêtes', 'جاهزة'),
                  _OrderFilter.all: tr(context, 'Toutes', 'الكل'),
                },
                selected: _filter,
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: AppSpacing.md),
              AppQuantityStepper(
                value: _quantity,
                min: 1,
                max: 500,
                step: 10,
                onChanged: (value) => setState(() => _quantity = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
