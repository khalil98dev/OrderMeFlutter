import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/app/forms/form_values.dart';
import 'package:medstore_admin/features/invoices/domain/invoice.dart';
import 'package:medstore_admin/features/invoices/domain/invoice_repository.dart';
import 'package:medstore_admin/features/invoices/presentation/new_invoice_cubit.dart';
import 'package:medstore_admin/features/orders/domain/admin_orders.dart';
import 'package:medstore_admin/features/orders/presentation/order_editor_cubit.dart';
import 'package:medstore_admin/features/security/domain/security.dart';
import 'package:medstore_admin/features/security/presentation/role_matrix_cubit.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrders extends Mock implements AdminOrderRepository {}

class _MockProducts extends Mock implements ProductRepository {}

class _MockInvoices extends Mock implements InvoiceRepository {}

class _MockSecurity extends Mock implements SecurityRepository {}

Product _product(String id, {num price = 1000}) => Product(
  id: id,
  clientId: 't1',
  name: 'Livre $id',
  type: ProductType.guide,
  isAvailable: true,
  hasImage: false,
  createdAt: DateTime(2026, 11),
  price: price,
);

Order _order({OrderStatus status = OrderStatus.pending}) => Order(
  id: 'o1',
  number: 1042,
  clientId: 't1',
  clientName: 'Amina',
  status: status,
  total: 2000,
  placedAt: DateTime(2026, 11, 4),
  lines: const [
    OrderLine(
      id: 'l1',
      productId: 'p1',
      productName: 'Livre p1',
      unitPrice: 1000,
      quantity: 2,
      lineTotal: 2000,
    ),
  ],
  history: const [],
);

UninvoicedProduct _row(String productId, int quantity, {num price = 500}) => UninvoicedProduct(
  productId: productId,
  productName: 'Livre $productId',
  unitPrice: price,
  quantity: quantity,
  amount: price * quantity,
  orders: const [],
);

Invoice _invoice() => Invoice(
  summary: InvoiceSummary(
    id: 'i1',
    number: 1,
    label: 'INV-000001',
    clientId: 't1',
    issueDate: DateTime(2026, 11, 5),
    dueDate: DateTime(2026, 11, 30),
    total: 1500,
    isVoided: false,
  ),
  paymentTerms: PaymentTerms.endOfMonth,
  lines: const [],
  payments: const [],
);

const _matrix = RoleMatrix(
  role: 'Client',
  description: 'Enseignants',
  resources: [
    ResourceMatrix(
      name: 'Product',
      available: {ResourceAction.read, ResourceAction.set},
      granted: {},
      fields: [
        FieldMatrix(name: 'Price', available: {FieldAction.read}, granted: {}),
      ],
    ),
    ResourceMatrix(name: 'Order', available: {ResourceAction.read}, granted: {}, fields: []),
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(const OrderDraft());
    registerFallbackValue(const ProductQuery());
    registerFallbackValue(const InvoiceDraft(clientId: null, available: []));
    registerFallbackValue(<Grant>[]);
  });

  group('OrderEditorCubit', () {
    late _MockOrders orders;
    late _MockProducts products;

    OrderEditorCubit cubit({Order? existing}) => OrderEditorCubit(
      placeOrder: PlaceOrder(orders),
      reviseOrder: ReviseOrder(orders),
      watchProducts: WatchProducts(products),
      existing: existing,
    );

    setUp(() {
      orders = _MockOrders();
      products = _MockProducts();
      when(() => products.watchProducts(any(), refresh: any(named: 'refresh'))).thenAnswer(
        (_) => Stream.value(
          Result.ok(
            PagedList(items: [_product('p1'), _product('p2')], page: 1, pageSize: 100, totalCount: 2),
          ),
        ),
      );
    });

    blocTest<OrderEditorCubit, OrderEditorState>(
      'choosing a teacher loads only their available products',
      build: cubit,
      act: (cubit) => cubit.chooseTeacher('t1', 'Amina'),
      verify: (cubit) {
        expect(cubit.state.products.map((p) => p.id), ['p1', 'p2']);
        final query =
            verify(() => products.watchProducts(captureAny(), refresh: false)).captured.single
                as ProductQuery;
        expect(query.clientId, 't1');
        expect(query.isAvailable, isTrue);
      },
    );

    blocTest<OrderEditorCubit, OrderEditorState>(
      'adding a product twice adds a copy; the total follows',
      build: cubit,
      act: (cubit) async {
        await cubit.chooseTeacher('t1', 'Amina');
        cubit
          ..add(_product('p1'))
          ..add(_product('p1'))
          ..add(_product('p2', price: 500));
      },
      verify: (cubit) {
        expect(cubit.state.draft.lines.map((line) => line.quantity), [2, 1]);
        expect(cubit.state.draft.total, 2500);
      },
    );

    blocTest<OrderEditorCubit, OrderEditorState>(
      'an empty order is not sent',
      build: cubit,
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        expect(cubit.state.problems, {OrderDraftProblem.teacherRequired, OrderDraftProblem.linesRequired});
        verifyNever(() => orders.place(any()));
      },
    );

    blocTest<OrderEditorCubit, OrderEditorState>(
      'a new order is placed and reports its number',
      setUp: () => when(() => orders.place(any())).thenAnswer((_) async => Result.ok(_order())),
      build: cubit,
      act: (cubit) async {
        await cubit.chooseTeacher('t1', 'Amina');
        cubit.add(_product('p1'));
        await cubit.save();
      },
      verify: (cubit) => expect(cubit.state.saved, 1042),
    );

    blocTest<OrderEditorCubit, OrderEditorState>(
      'a revision keeps the teacher, starts from the order\'s lines and sends the whole list',
      setUp: () => when(() => orders.revise(any(), any())).thenAnswer((_) async => const Result.ok(null)),
      build: () => cubit(existing: _order()),
      act: (cubit) async {
        await cubit.start();
        await cubit.chooseTeacher('t2', 'Other'); // ignored: the owner of an order never changes
        cubit.setQuantity('p1', 5);
        await cubit.save();
      },
      verify: (cubit) {
        final draft = verify(() => orders.revise('o1', captureAny())).captured.single as OrderDraft;
        expect(draft.clientId, 't1');
        expect(draft.lines.single.quantity, 5);
        expect(cubit.state.saved, 0);
      },
    );

    blocTest<OrderEditorCubit, OrderEditorState>(
      'a refusal is kept for the page and the order can be saved again',
      setUp: () =>
          when(() => orders.place(any())).thenAnswer((_) async => const Result.err(NetworkFailure())),
      build: cubit,
      act: (cubit) async {
        await cubit.chooseTeacher('t1', 'Amina');
        cubit.add(_product('p1'));
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.failure, isA<NetworkFailure>());
        expect(cubit.state.isSaving, isFalse);
        expect(cubit.state.saved, isNull);
      },
    );
  });

  group('NewInvoiceCubit', () {
    late _MockInvoices invoices;

    NewInvoiceCubit cubit() =>
        NewInvoiceCubit(listUninvoiced: ListUninvoiced(invoices), issueInvoice: IssueInvoice(invoices));

    setUp(() {
      invoices = _MockInvoices();
      when(
        () => invoices.uninvoiced('t1'),
      ).thenAnswer((_) async => Result.ok([_row('p1', 3), _row('p2', 2, price: 250)]));
    });

    blocTest<NewInvoiceCubit, NewInvoiceState>(
      'a teacher\'s uninvoiced copies come all selected',
      build: cubit,
      act: (cubit) => cubit.chooseTeacher('t1', 'Amina'),
      verify: (cubit) {
        expect(cubit.state.draft.total, 3 * 500 + 2 * 250);
        expect(cubit.state.isLoading, isFalse);
      },
    );

    blocTest<NewInvoiceCubit, NewInvoiceState>(
      'nothing selected is not sent; a selection is issued',
      setUp: () => when(() => invoices.issue(any())).thenAnswer((_) async => Result.ok(_invoice())),
      build: cubit,
      act: (cubit) async {
        await cubit.chooseTeacher('t1', 'Amina');
        cubit
          ..setQuantity('p1@500', 0)
          ..setQuantity('p2@250', 0);
        await cubit.issue();
        cubit.setQuantity('p1@500', 2);
        await cubit.issue();
      },
      verify: (cubit) {
        final draft = verify(() => invoices.issue(captureAny())).captured.single as InvoiceDraft;
        expect(draft.selected.single.productId, 'p1');
        expect(draft.quantityOf(draft.selected.single), 2);
        expect(cubit.state.issued?.summary.label, 'INV-000001');
      },
    );

    test('more than the copies available is a problem', () {
      final draft = InvoiceDraft(clientId: 't1', available: [_row('p1', 3)]).setQuantity('p1@500', 4);
      expect(draft.validate(), {InvoiceDraftProblem.quantityTooHigh});
    });
  });

  group('RoleMatrixCubit', () {
    late _MockSecurity security;

    RoleMatrixCubit cubit() => RoleMatrixCubit(
      getMatrix: GetRoleMatrix(security),
      saveMatrix: SaveRoleMatrix(security),
      role: 'Client',
    );

    setUp(() {
      security = _MockSecurity();
      when(() => security.matrix('Client')).thenAnswer((_) async => const Result.ok(_matrix));
      when(() => security.setPermissions(any(), any())).thenAnswer((_) async => const Result.ok(null));
    });

    blocTest<RoleMatrixCubit, RoleMatrixState>(
      'ticking makes it dirty; saving sends one grant per resource with anything ticked',
      build: cubit,
      act: (cubit) async {
        await cubit.load();
        cubit
          ..toggle('Product', ResourceAction.read)
          ..toggleField('Product', 'Price', FieldAction.read);
        expect(cubit.state.isDirty, isTrue);
        await cubit.save();
      },
      verify: (cubit) {
        final grants =
            verify(() => security.setPermissions('Client', captureAny())).captured.single as List<Grant>;
        expect(grants, const [
          Grant(
            resource: 'Product',
            actions: {ResourceAction.read},
            fields: {
              'Price': {FieldAction.read},
            },
          ),
        ]);
        expect(cubit.state.isDirty, isFalse);
        expect(cubit.state.justSaved, isTrue);
      },
    );

    blocTest<RoleMatrixCubit, RoleMatrixState>(
      'reverting puts back what the server has; nothing to save is not sent',
      build: cubit,
      act: (cubit) async {
        await cubit.load();
        cubit
          ..toggle('Order', ResourceAction.read)
          ..revert();
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.matrix, _matrix);
        verifyNever(() => security.setPermissions(any(), any()));
      },
    );
  });

  group('parseMoney', () {
    test('accepts spaces and a decimal comma; refuses 0, negatives and 3 decimals', () {
      expect(parseMoney('15 000'), 15000);
      expect(parseMoney('1250,5'), 1250.5);
      expect(parseMoney('0'), isNull);
      expect(parseMoney('-5'), isNull);
      expect(parseMoney('1.234'), isNull);
      expect(parseMoney('abc'), isNull);
    });
  });

  group('OrderStatus moves', () {
    test('the team moves forward or cancels; a note is needed once preparation started', () {
      expect(OrderStatus.pending.staffMoves, [OrderStatus.inPreparation, OrderStatus.cancelled]);
      expect(OrderStatus.delivered.staffMoves, isEmpty);
      expect(OrderStatus.ready.cancelNeedsNote, isTrue);
      expect(OrderStatus.pending.cancelNeedsNote, isFalse);
      expect(OrderStatus.ready.staffCanRevise, isFalse);
    });
  });
}
