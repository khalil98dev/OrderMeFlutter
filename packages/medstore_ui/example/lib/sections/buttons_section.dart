import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class ButtonsSection extends StatelessWidget {
  const ButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final save = tr(context, 'Enregistrer', 'حفظ');
    return GallerySection(
      title: tr(context, 'Boutons', 'الأزرار'),
      components: 'AppButton · AppIconButton',
      children: [
        Demo(
          label: 'AppButtonVariant',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(label: save, onPressed: () {}),
              AppButton(label: save, variant: AppButtonVariant.tinted, onPressed: () {}),
              AppButton(label: save, variant: AppButtonVariant.plain, onPressed: () {}),
              AppButton(
                label: tr(context, 'Supprimer', 'حذف'),
                variant: AppButtonVariant.destructive,
                icon: AppIcons.delete,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Demo(
          label: 'isLoading · disabled · small · expand',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppButton(label: save, isLoading: true, onPressed: () {}),
                  const SizedBox(width: AppSpacing.xs),
                  AppButton(label: save, onPressed: null),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  AppButton(label: save, size: AppButtonSize.small, onPressed: () {}),
                  const SizedBox(width: AppSpacing.xs),
                  AppButton(
                    label: save,
                    size: AppButtonSize.small,
                    variant: AppButtonVariant.tinted,
                    icon: AppIcons.add,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(label: AppStrings.of(context).signIn, expand: true, onPressed: () {}),
            ],
          ),
        ),
        Demo(
          label: 'AppIconButton',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              AppIconButton(icon: AppIcons.edit, label: tr(context, 'Modifier', 'تعديل'), onPressed: () {}),
              AppIconButton(
                icon: AppIcons.print,
                label: tr(context, 'Imprimer', 'طباعة'),
                tone: AppTone.accent,
                filled: true,
                onPressed: () {},
              ),
              AppIconButton(
                icon: AppIcons.delete,
                label: tr(context, 'Supprimer', 'حذف'),
                tone: AppTone.danger,
                filled: true,
                onPressed: () {},
              ),
              AppIconButton(
                icon: AppIcons.check,
                label: tr(context, 'Livrée', 'تم التسليم'),
                tone: AppTone.success,
                filled: true,
                size: 40,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
