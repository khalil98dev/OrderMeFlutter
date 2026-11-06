import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class DisplaySection extends StatelessWidget {
  const DisplaySection({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return GallerySection(
      title: tr(context, 'Affichage', 'العرض'),
      components: 'AppBadge · AppMoney · AppAvatar · AppMetricCard · AppLogo',
      children: [
        Demo(
          label: 'AppBadge — order status → tone',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(
                label: tr(context, 'En attente', 'في الانتظار'),
                tone: AppTone.warning,
                icon: AppIcons.clock,
              ),
              AppBadge(label: tr(context, 'En préparation', 'قيد التحضير'), tone: AppTone.info),
              AppBadge(label: tr(context, 'Prête', 'جاهزة'), tone: AppTone.success),
              AppBadge(label: tr(context, 'Livrée', 'تم التسليم'), tone: AppTone.neutral),
              AppBadge(label: tr(context, 'Annulée', 'ملغاة'), tone: AppTone.danger),
            ],
          ),
        ),
        const Demo(
          label: 'AppMoney · AppAvatar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMoney(1250),
              AppMoney(1234567, style: AppTypography.title2, tone: AppTone.success),
              AppMoney(48000, tone: AppTone.danger),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  AppAvatar(name: 'Amina Benali'),
                  SizedBox(width: AppSpacing.xs),
                  AppAvatar(name: 'كريم آيت سعيد'),
                  SizedBox(width: AppSpacing.xs),
                  AppAvatar(name: 'prof.yacine', size: 48),
                  SizedBox(width: AppSpacing.xs),
                  AppLogo(size: 48),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 210,
          child: AppMetricCard(
            label: tr(context, 'À préparer', 'للتحضير'),
            value: '14',
            icon: AppIcons.cart,
            tone: AppTone.warning,
            caption: tr(context, '3 depuis ce matin', '3 منذ الصباح'),
          ),
        ),
        SizedBox(
          width: 210,
          child: AppMetricCard(
            label: tr(context, 'Encaissé ce mois', 'المحصّل هذا الشهر'),
            value: MoneyFormat.dzd(386500, locale),
            icon: AppIcons.wallet,
            tone: AppTone.success,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
