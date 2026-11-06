import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_teacher/features/cart/cart_cubit.dart';

Product _book(String id, {num? price = 300, bool available = true}) => Product(
  id: id,
  clientId: 'c7',
  name: 'Book $id',
  type: ProductType.guide,
  price: price,
  isAvailable: available,
  hasImage: false,
  createdAt: DateTime(2026, 11, 6),
);

void main() {
  late CartCubit cart;

  setUp(() => cart = CartCubit());
  tearDown(() => cart.close());

  test('adding the same book again adds copies to its line', () {
    cart
      ..add(_book('a'))
      ..add(_book('a'), quantity: 2)
      ..add(_book('b'));

    expect(cart.state.lines, hasLength(2));
    expect(cart.state.quantityOf('a'), 3);
    expect(cart.state.copies, 4);
    expect(cart.state.total, 1200);
  });

  test('a quantity of zero removes the line; clear empties the cart', () {
    cart
      ..add(_book('a'))
      ..add(_book('b'))
      ..setQuantity('a', 0);

    expect(cart.state.quantityOf('a'), 0);
    expect(cart.state.lines.single.product.id, 'b');

    cart.clear();
    expect(cart.state.isEmpty, isTrue);
  });

  test('the total is unknown while one price is hidden', () {
    cart
      ..add(_book('a'))
      ..add(_book('b', price: null));

    expect(cart.state.total, isNull);
    expect(cart.state.canOrder, isTrue);
  });

  test('an unavailable book blocks the order until it is removed', () {
    cart
      ..add(_book('a'))
      ..add(_book('b', available: false));

    expect(cart.state.canOrder, isFalse);
    cart.remove('b');
    expect(cart.state.canOrder, isTrue);
  });
}
