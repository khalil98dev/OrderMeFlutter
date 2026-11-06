import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/widgets/soft_card.dart';
import '../orders/domain/my_orders.dart';
import '../orders/presentation/orders_page.dart';
import 'cart_cubit.dart';

/// The cart: each product with its copies, a note for the team, the total, and "Place order".
///
/// Expects [CartCubit] (the app's) and a `SubmitCubit<Order>` with [PlaceOrder] above it; the route
/// provides them. A placed order empties the cart and opens the order.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final cart = context.read<CartCubit>();
    final placeOrder = context.read<PlaceOrder>();
    final lines = [
      for (final line in cart.state.lines) NewOrderLine(productId: line.product.id, quantity: line.quantity),
    ];
    await context.read<SubmitCubit<Order>>().run(
      () => placeOrder(PlaceOrderParams(lines: lines, notes: _notes.text)),
    );
  }

  Future<void> _placed(Order order) async {
    context.read<CartCubit>().clear();
    unawaited(context.read<MyOrdersCubit>().load());
    final strings = AppStrings.of(context);
    final open = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialog) => CupertinoAlertDialog(
        title: Column(
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill, size: 48, color: AppColors.signal.resolveFrom(dialog)),
            const SizedBox(height: AppSpacing.xs),
            Text(strings.orderSentTitle),
          ],
        ),
        content: Text(strings.orderSentMessage(order.number)),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.of(dialog).pop(false), child: Text(strings.close)),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(strings.viewOrder),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (open ?? false) {
      context.go('/orders/${order.id}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cart = context.watch<CartCubit>().state;

    return BlocListener<SubmitCubit<Order>, SubmitState<Order>>(
      listenWhen: (previous, current) => current.status == SubmitStatus.done,
      listener: (context, state) => _placed(state.value!),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(strings.cart),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.pop(),
            child: Text(strings.close),
          ),
          border: null,
        ),
        child: SafeArea(
          child: cart.isEmpty
              ? AppEmptyState(
                  icon: CupertinoIcons.cart,
                  title: strings.cartEmptyTitle,
                  message: strings.cartEmptyMessage,
                  action: AppButton(label: strings.browseProducts, onPressed: () => context.pop()),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          for (final line in cart.lines) ...[
                            _CartLineTile(line: line),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (cart.hasUnavailable) ...[
                            AppMessage(text: strings.cartUnavailableHint, tone: AppTone.warning),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          AppTextField(
                            label: strings.fieldNotes,
                            placeholder: strings.orderNotesHint,
                            controller: _notes,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    _Summary(cart: cart, onPlace: _place),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cart = context.read<CartCubit>();
    final product = line.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(product.id),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.destructive.resolveFrom(context),
          borderRadius: SoftCard.radius,
        ),
        child: const Icon(CupertinoIcons.delete, color: AppColors.onBrand),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            AppCoverImage(image: context.read<ProductImages>().cover(product), width: 56),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                  ),
                  const SizedBox(height: 2),
                  if (product.isAvailable)
                    ProductPrice(price: line.total, style: AppTypography.subheadline)
                  else
                    const ProductAvailabilityBadge(isAvailable: false),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      AppQuantityStepper(
                        value: line.quantity,
                        max: CartCubit.maxCopies,
                        onChanged: (value) => cart.setQuantity(product.id, value),
                      ),
                      const Spacer(),
                      AppIconButton(
                        icon: CupertinoIcons.trash,
                        label: strings.remove,
                        tone: AppTone.danger,
                        onPressed: () => cart.remove(product.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The bottom sheet-like bar: copies, total and the main button.
class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.onPlace});

  final CartState cart;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final submit = context.watch<SubmitCubit<Order>>().state;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [BoxShadow(color: Color(0x1412131A), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.copiesCount(cart.copies),
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.textSecondary.resolveFrom(context),
                    ),
                  ),
                ),
                Text(
                  strings.total,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.textSecondary.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                ProductPrice(price: cart.total, style: AppTypography.title3),
              ],
            ),
            if (submit.status == SubmitStatus.failed && submit.failure != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppMessage(text: failureText(strings, submit.failure!)),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: strings.placeOrder,
              icon: CupertinoIcons.paperplane_fill,
              expand: true,
              isLoading: submit.isBusy,
              onPressed: cart.canOrder ? onPlace : null,
            ),
          ],
        ),
      ),
    );
  }
}
