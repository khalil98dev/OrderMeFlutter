import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

/// Copies of one product in the cart.
final class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  /// Null when the teacher may not see the price.
  num? get total => switch (product.price) {
    final price? => price * quantity,
    null => null,
  };

  @override
  List<Object?> get props => [product, quantity];
}

final class CartState extends Equatable {
  const CartState({this.lines = const []});

  /// In the order the products were first added.
  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  /// Every copy, all products together (the badge).
  int get copies => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Null when one of the prices is hidden: the server computes the real total anyway.
  num? get total {
    num sum = 0;
    for (final line in lines) {
      final lineTotal = line.total;
      if (lineTotal == null) return null;
      sum += lineTotal;
    }
    return sum;
  }

  /// A product that became unavailable must be removed first (the server would refuse the order).
  bool get hasUnavailable => lines.any((line) => !line.product.isAvailable);

  bool get canOrder => lines.isNotEmpty && !hasUnavailable;

  int quantityOf(String productId) =>
      lines.where((line) => line.product.id == productId).firstOrNull?.quantity ?? 0;

  @override
  List<Object?> get props => [lines];
}

/// The teacher's cart: lives for the session (one instance), emptied when an order is placed or the
/// teacher signs out. Each product appears once; adding it again adds copies.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  static const maxCopies = 9999;

  void add(Product product, {int quantity = 1}) {
    final current = state.quantityOf(product.id);
    if (current == 0) {
      emit(
        CartState(
          lines: [
            ...state.lines,
            CartLine(product: product, quantity: quantity.clamp(1, maxCopies)),
          ],
        ),
      );
    } else {
      setQuantity(product.id, current + quantity);
    }
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    emit(
      CartState(
        lines: [
          for (final line in state.lines)
            line.product.id == productId
                ? CartLine(product: line.product, quantity: quantity.clamp(1, maxCopies))
                : line,
        ],
      ),
    );
  }

  void remove(String productId) =>
      emit(CartState(lines: [...state.lines.where((line) => line.product.id != productId)]));

  void clear() => emit(const CartState());
}
