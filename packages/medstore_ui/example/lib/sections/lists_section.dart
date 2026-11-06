import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class ListsSection extends StatelessWidget {
  const ListsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GallerySection(
      title: tr(context, 'Listes', 'القوائم'),
      components: 'AppSection · AppListTile · AppCard(onTap)',
      children: [
        SizedBox(
          width: 420,
          child: AppSection(
            header: strings.navTeachers,
            footer: tr(
              context,
              'Touchez un enseignant pour voir ses commandes.',
              'اضغط على أستاذ لعرض طلباته.',
            ),
            dividerIndent: 64,
            children: [
              AppListTile(
                leading: const AppAvatar(name: 'Amina Benali'),
                title: 'Amina Benali',
                subtitle: tr(context, 'Lycée Ibn Khaldoun', 'ثانوية ابن خلدون'),
                trailing: AppBadge(label: tr(context, '2 prêtes', '2 جاهزة'), tone: AppTone.success),
                onTap: () {},
              ),
              AppListTile(
                leading: const AppAvatar(name: 'Karim Ait Said'),
                title: 'Karim Ait Said',
                subtitle: tr(context, 'CEM El Feth', 'متوسطة الفتح'),
                trailing: const AppMoney(12500, style: AppTypography.subheadline),
                onTap: () {},
              ),
              AppListTile(
                leading: const AppAvatar(name: 'Yacine Haddad'),
                title: 'Yacine Haddad',
                subtitle: tr(context, 'Aucune commande', 'لا توجد طلبات'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 420,
          child: AppSection(
            header: strings.navProfile,
            children: [
              AppListTile(
                leading: Icon(AppIcons.language, color: AppColors.accent.resolveFrom(context)),
                title: strings.language,
                trailing: Text(tr(context, 'Français', 'العربية')),
                onTap: () {},
              ),
              AppListTile(title: strings.signOut, destructive: true, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
