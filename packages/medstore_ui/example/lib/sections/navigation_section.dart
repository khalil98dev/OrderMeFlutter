import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  var _selected = 1;
  var _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GallerySection(
      title: tr(context, 'Navigation', 'التنقل'),
      components: 'AppSidebar · AppPageHeader',
      children: [
        SizedBox(
          width: 1040,
          height: 420,
          child: ClipRRect(
            borderRadius: AppRadii.mdRadius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSidebar(
                  title: strings.appName,
                  subtitle: strings.adminSubtitle,
                  collapsed: _collapsed,
                  toggleLabel: _collapsed ? strings.expandSidebar : strings.collapseSidebar,
                  onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
                  selectedIndex: _selected,
                  onSelected: (index) => setState(() => _selected = index),
                  items: [
                    AppSidebarItem(
                      label: strings.navDashboard,
                      icon: CupertinoIcons.square_grid_2x2,
                      section: strings.sectionOperations,
                    ),
                    AppSidebarItem(
                      label: strings.navOrders,
                      icon: CupertinoIcons.cart,
                      activeIcon: CupertinoIcons.cart_fill,
                      section: strings.sectionOperations,
                    ),
                    AppSidebarItem(
                      label: strings.navInvoices,
                      icon: CupertinoIcons.doc_text,
                      section: strings.sectionFinance,
                    ),
                    AppSidebarItem(
                      label: strings.navSettings,
                      icon: CupertinoIcons.gear,
                      section: strings.sectionSystem,
                    ),
                  ],
                ),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.canvas.resolveFrom(context),
                    child: Padding(
                      padding: AppSpacing.screenDesktop,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppPageHeader(
                            title: strings.navOrders,
                            subtitle: tr(context, '14 à préparer', '14 للتحضير'),
                            actions: [
                              AppIconButton(
                                icon: CupertinoIcons.arrow_clockwise,
                                label: strings.retry,
                                onPressed: () {},
                              ),
                              AppButton(
                                label: tr(context, 'Nouvelle commande', 'طلب جديد'),
                                icon: CupertinoIcons.add,
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppSearchField(onChanged: (_) {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
