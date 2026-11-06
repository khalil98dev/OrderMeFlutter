import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

class MotionSection extends StatefulWidget {
  const MotionSection({super.key});

  @override
  State<MotionSection> createState() => _MotionSectionState();
}

class _MotionSectionState extends State<MotionSection> {
  final _cartKey = GlobalKey<AppBounceTargetState>();
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    final brand = AppTone.brand.resolve(context);
    return GallerySection(
      title: tr(context, 'Mouvement', 'الحركة'),
      components: 'AppBounceTarget · flyToTarget',
      children: [
        Demo(
          label: tr(
            context,
            'Ajouter au panier (tapez vite plusieurs fois)',
            'أضف إلى السلة (اضغط عدة مرات بسرعة)',
          ),
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppBounceTarget(
                  key: _cartKey,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.cart, size: 30, color: brand.foreground),
                      const SizedBox(width: AppSpacing.xxs),
                      AppBadge(label: '$_count', tone: AppTone.brand),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  for (final product in _demoProducts)
                    Expanded(
                      child: _ProductTile(
                        product: product,
                        cartKey: _cartKey,
                        onAdd: () => setState(() => _count++),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

typedef _DemoProduct = ({String fr, String ar, IconData icon, AppTone tone});

const List<_DemoProduct> _demoProducts = [
  (fr: 'Physique 1re', ar: 'فيزياء أولى', icon: AppIcons.products, tone: AppTone.info),
  (fr: 'Maths 2e', ar: 'رياضيات ثانية', icon: AppIcons.invoices, tone: AppTone.success),
  (fr: 'Chimie Bac', ar: 'كيمياء باك', icon: AppIcons.lab, tone: AppTone.warning),
];

/// A product tile. Its own key on the cover makes the flight start from the cover, not the whole tile.
class _ProductTile extends StatefulWidget {
  const _ProductTile({required this.product, required this.cartKey, required this.onAdd});

  final _DemoProduct product;
  final GlobalKey<AppBounceTargetState> cartKey;
  final VoidCallback onAdd;

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  final _coverKey = GlobalKey();

  void _add() {
    widget.onAdd(); // state first; the flight is decoration
    final coverContext = _coverKey.currentContext;
    if (coverContext == null) return;
    unawaited(
      flyToTarget(
        coverContext,
        target: widget.cartKey,
        child: _Cover(icon: widget.product.icon, tone: widget.product.tone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Column(
        children: [
          _Cover(key: _coverKey, icon: product.icon, tone: product.tone),
          const SizedBox(height: AppSpacing.xs),
          Text(tr(context, product.fr, product.ar), style: AppTypography.footnote),
          const SizedBox(height: AppSpacing.xs),
          AppButton(label: tr(context, 'Ajouter', 'أضف'), size: AppButtonSize.small, onPressed: _add),
        ],
      ),
    );
  }
}

/// A stand-in product cover.
class _Cover extends StatelessWidget {
  const _Cover({super.key, required this.icon, required this.tone});

  final IconData icon;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    return SizedBox.square(
      dimension: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.background, borderRadius: AppRadii.mdRadius),
        child: Icon(icon, color: colors.foreground, size: 28),
      ),
    );
  }
}
