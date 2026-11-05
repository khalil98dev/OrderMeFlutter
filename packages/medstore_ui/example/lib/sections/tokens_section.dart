import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class TokensSection extends StatelessWidget {
  const TokensSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: tr(context, 'Couleurs et texte', 'الألوان والنصوص'),
      components: 'AppTone · AppColors · AppTypography',
      children: [
        Demo(
          label: 'AppTone',
          width: 660,
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [for (final tone in AppTone.values) _ToneSwatch(tone: tone)],
          ),
        ),
        const Demo(
          label: 'AppTypography',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Sample('title1', AppTypography.title1),
              _Sample('title3', AppTypography.title3),
              _Sample('headline', AppTypography.headline),
              _Sample('body', AppTypography.body),
              _Sample('footnote', AppTypography.footnote),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToneSwatch extends StatelessWidget {
  const _ToneSwatch({required this.tone});

  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 48,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadii.smRadius,
            border: Border.all(color: colors.foreground, width: 2),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(tone.name, style: AppTypography.caption.copyWith(color: colors.foreground)),
      ],
    );
  }
}

class _Sample extends StatelessWidget {
  const _Sample(this.name, this.style);

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name · ${tr(context, 'Commande prête', 'الطلب جاهز')}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
    );
  }
}
