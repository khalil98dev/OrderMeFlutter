import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../domain/product_draft.dart';

/// The cover part of the product form: a preview, "Choose an image" / "Replace", and "Remove".
///
/// Nothing is uploaded here: the choice is reported as a [CoverChange] and sent when the form is saved.
class CoverEditor extends StatelessWidget {
  const CoverEditor({
    super.key,
    required this.current,
    required this.change,
    required this.onChanged,
    this.error,
  });

  /// The product's cover on the server, or null.
  final ImageProvider? current;
  final CoverChange change;
  final ValueChanged<CoverChange> onChanged;
  final String? error;

  static const _imageTypes = XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png', 'webp']);

  /// What the cover will be once saved.
  ImageProvider? get _preview => switch (change) {
    NewCover(:final bytes) => MemoryImage(bytes),
    RemoveCover() => null,
    KeepCover() => current,
  };

  Future<void> _choose() async {
    final file = await openFile(acceptedTypeGroups: const [_imageTypes]);
    if (file == null) return; // the user closed the dialog
    onChanged(NewCover(bytes: await file.readAsBytes(), fileName: file.name));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final preview = _preview;
    final error = this.error;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.fieldCover,
            style: AppTypography.footnote.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.resolveFrom(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(child: AppCoverImage(image: preview, width: 180)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.imageHint,
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(color: AppColors.destructive.resolveFrom(context)),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: preview == null ? strings.chooseImage : strings.replaceImage,
            icon: AppIcons.image,
            variant: AppButtonVariant.tinted,
            onPressed: _choose,
          ),
          if (preview != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: strings.removeImage,
              variant: AppButtonVariant.plain,
              // A new, unsaved image is just dropped; a saved one is removed on save.
              onPressed: () => onChanged(current == null ? const KeepCover() : const RemoveCover()),
            ),
          ],
        ],
      ),
    );
  }
}
