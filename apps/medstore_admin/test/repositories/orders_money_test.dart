import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_admin/features/debts/data/debt_repository_impl.dart';
import 'package:medstore_admin/features/debts/domain/debts.dart';
import 'package:medstore_admin/features/invoices/data/invoice_repository_impl.dart';
import 'package:medstore_admin/features/invoices/domain/invoice.dart';
import 'package:medstore_admin/features/invoices/domain/invoice_repository.dart';
import 'package:medstore_admin/features/orders/data/admin_order_repository_impl.dart';
import 'package:medstore_admin/features/orders/domain/admin_orders.dart';
import 'package:medstore_admin/features/wallets/data/wallet_repository_impl.dart';
import 'package:medstore_admin/features/wallets/domain/wallet.dart';
import 'package:medstore_core/medstore_core.dart';

import '../helpers/fake_api.dart';

const _orderJson = {
  'id': 'o1',
  'number': 1042,
  'clientId': 't1',
  'clientName': 'Amina',
  'status': 'Pending',
  'total': 2400,
  'placedAt': '2026-11-04T10:00:00+00:00',
  'lines': [
    {
      'id': 'l1',
      'productId': 'p1',
      'productName': 'Maths',
      'unitPrice': 1200,
      'quantity': 2,
      'lineTotal': 2400,
    },
  ],
  'history': [
    {
      'status': 'Pending',
      'changedAt': '2026-11-04T10:00:00+00:00',
      'actor': 'Staff',
      'changedByName': 'admin',
    },
  ],
};

const _transactionJson = {
  'id': 'w1',
  'type': 'Deposit',
  'amount': 5000,
  'balanceAfter': 5000,
  'occurredAt': '2026-11-04T10:00:00+00:00',
  'method': 'Cash',
  'receiptNumber': 42,
  'receiptLabel': 'REC-000042',
  'isVoided': false,
  'hasReceipt': true,
};

const _invoiceJson = {
  'id': 'i1',
  'number': 1,
  'label': 'INV-000001',
  'clientId': 't1',
  'clientName': 'Amina',
  'issueDate': '2026-11-04',
  'dueDate': '2026-11-30',
  'paymentTerms': 'EndOfMonth',
  'total': 2400,
  'amountPaid': 400,
  'amountDue': 2000,
  'paymentStatus': 'PartiallyPaid',
  'isVoided': false,
  'isOverdue': false,
  'lines': [
    {
      'id': 'il1',
      'productId': 'p1',
      'productName': 'Maths',
      'unitPrice': 1200,
      'quantity': 2,
      'lineTotal': 2400,
      'orders': [
        {'orderId': 'o1', 'orderNumber': 1042, 'quantity': 2},
      ],
    },
  ],
  'payments': [
    {'amount': 400, 'paidAt': '2026-11-04T10:00:00+00:00'},
  ],
};

const _debtJson = {
  'id': 'd1',
  'clientId': 't1',
  'description': 'Avant l\'application',
  'amount': 3000,
  'amountPaid': 0,
  'amountDue': 3000,
  'amountWrittenOff': 0,
  'dueDate': '2026-11-05',
  'createdAt': '2026-11-05T09:00:00+00:00',
  'isOverdue': false,
};

void main() {
  late FakeApi api;
  setUp(() => api = FakeApi());

  group('AdminOrderRepositoryImpl', () {
    late AdminOrderRepositoryImpl repository;
    setUp(() => repository = AdminOrderRepositoryImpl(api.client));

    test('lists with status, number and a period whose last day is included', () async {
      api.reply = (_) => FakeReply(paged([]));
      await repository.list(
        OrderFilter(
          status: OrderStatus.ready,
          number: 1042,
          from: DateTime(2026, 11),
          to: DateTime(2026, 11, 30),
        ),
      );
      expect(api.last.path, '/api/admin/orders');
      expect(api.last.queryParameters, {
        'status': 'Ready',
        'number': 1042,
        'from': '2026-11-01',
        'to': '2026-12-01', // the API's "to" is exclusive
        'page': 1,
        'pageSize': 50,
      });
    });

    test('places an order for a teacher, sending products and quantities only', () async {
      api.reply = (_) => const FakeReply(_orderJson, status: 201);
      const draft = OrderDraft(
        clientId: 't1',
        notes: ' ',
        lines: [DraftLine(productId: 'p1', productName: 'Maths', unitPrice: 1200, quantity: 2)],
      );

      final order = okValue(await repository.place(draft));

      expect(api.lastBody, {
        'clientId': 't1',
        'notes': null,
        'lines': [
          {'productId': 'p1', 'quantity': 2},
        ],
      });
      expect(order.number, 1042);
      expect(order.history.single.actor, OrderActor.staff);
    });

    test('revises and moves the status with a note', () async {
      await repository.revise('o1', const OrderDraft(lines: []));
      expect(api.last.method, 'PUT');
      expect(api.last.path, '/api/admin/orders/o1');

      await repository.changeStatus('o1', OrderStatus.cancelled, note: 'Papier épuisé');
      expect(api.last.path, '/api/admin/orders/o1/status');
      expect(api.lastBody, {'status': 'Cancelled', 'note': 'Papier épuisé'});
    });

    test('marking Ready reads the invoice it issued and what is left as debt', () async {
      api.reply = (_) => const FakeReply({
        'orderId': 'o1',
        'status': 'Ready',
        'invoiceId': 'i1',
        'invoiceLabel': 'INV-000042',
        'invoiceTotal': 45000,
        'paidFromWallet': 10000,
        'amountDue': 35000,
      });
      final outcome = okValue(await repository.changeStatus('o1', OrderStatus.ready));
      expect(outcome.issuedInvoice, isTrue);
      expect(outcome.invoiceLabel, 'INV-000042');
      expect(outcome.paidFromWallet, 10000);
      expect(outcome.amountDue, 35000);
    });

    test('a move that issues nothing (or an empty answer) has no invoice', () async {
      final outcome = okValue(await repository.changeStatus('o1', OrderStatus.inPreparation));
      expect(outcome.issuedInvoice, isFalse);
    });

    test('a move the order does not allow is a conflict with the server sentence', () async {
      api.reply = (_) =>
          FakeReply(problem(409, title: 'An order that is Pending cannot become Delivered.'), status: 409);
      final failure = errOf(await repository.changeStatus('o1', OrderStatus.delivered));
      expect(failure, isA<ConflictFailure>());
      expect(failure.detail, contains('cannot become Delivered'));
    });
  });

  group('WalletRepositoryImpl', () {
    late WalletRepositoryImpl repository;
    setUp(() => repository = WalletRepositoryImpl(api.client));

    test('lists balances and one wallet', () async {
      api.reply = (_) => FakeReply(
        paged([
          {'clientId': 't1', 'clientName': 'Amina', 'balance': 5000, 'totalDeposited': 5000},
        ]),
      );
      final wallets = okValue(await repository.list(const WalletFilter(search: 'ami')));
      expect(api.last.queryParameters, {'search': 'ami', 'page': 1, 'pageSize': 50});
      expect(wallets.items.single.lastMovementAt, isNull);
    });

    test('lists the ledger by type and period', () async {
      api.reply = (_) => FakeReply(paged([_transactionJson]));
      final page = okValue(
        await repository.transactions(
          TransactionFilter(clientId: 't1', type: WalletTransactionType.deposit, from: DateTime(2026, 11, 1)),
        ),
      );
      expect(api.last.path, '/api/admin/wallets/t1/transactions');
      expect(api.last.queryParameters, {'type': 'Deposit', 'from': '2026-11-01', 'page': 1, 'pageSize': 50});
      expect(page.items.single.receiptLabel, 'REC-000042');
      expect(page.items.single.canBeVoided, isTrue);
    });

    test('records a deposit, a withdrawal, a settlement and a void', () async {
      api.reply = (_) => const FakeReply(_transactionJson, status: 201);
      await repository.deposit(
        't1',
        const DepositDraft(amount: 5000, method: PaymentMethod.bankTransfer, reference: 'VIR-1'),
      );
      expect(api.last.path, '/api/admin/wallets/t1/deposits');
      expect(api.lastBody, {'amount': 5000, 'method': 'BankTransfer', 'reference': 'VIR-1', 'note': null});

      await repository.withdraw('t1', const WithdrawalDraft(amount: 1000));
      expect(api.lastBody, {'amount': 1000, 'note': null});

      api.reply = (_) => const FakeReply({
        'clientId': 't1',
        'paid': 2000,
        'wallet': {'clientId': 't1', 'balance': 3000, 'totalDeposited': 5000},
      });
      final settled = okValue(await repository.settle('t1'));
      expect(settled.paid, 2000);
      expect(settled.wallet.balance, 3000);

      final reversalJson = Map<String, Object?>.of(_transactionJson)
        ..['type'] = 'Reversal'
        ..['amount'] = -5000;
      api.reply = (_) => FakeReply(reversalJson);
      final reversal = okValue(await repository.voidTransaction('w1', 'Erreur'));
      expect(api.last.path, '/api/admin/wallets/transactions/w1/void');
      expect(api.lastBody, {'reason': 'Erreur'});
      expect(reversal.type, WalletTransactionType.reversal);
    });

    test('downloads a receipt from the shared wallet endpoint', () async {
      api.reply = (_) => FakeReply(Uint8List.fromList([1, 2, 3]));
      expect(okValue(await repository.receipt('w1')), [1, 2, 3]);
      expect(api.last.path, '/api/wallet/transactions/w1/receipt');
    });

    test('a withdrawal above the balance is refused with its rule code', () async {
      api.reply = (_) => FakeReply(
        problem(
          400,
          errors: {
            'Wallet.InsufficientBalance': ['…'],
          },
        ),
        status: 400,
      );
      final failure = errOf(await repository.withdraw('t1', const WithdrawalDraft(amount: 999999)));
      expect((failure as ValidationFailure).errors.keys, ['Wallet.InsufficientBalance']);
    });
  });

  group('InvoiceRepositoryImpl', () {
    late InvoiceRepositoryImpl repository;
    setUp(() => repository = InvoiceRepositoryImpl(api.client));

    test('lists with payment filters', () async {
      api.reply = (_) => FakeReply(paged([_invoiceJson]));
      final page = okValue(
        await repository.list(
          const InvoiceFilter(clientId: 't1', paymentStatus: InvoicePaymentStatus.unpaid, onlyOverdue: true),
        ),
      );
      expect(api.last.queryParameters, {
        'clientId': 't1',
        'paymentStatus': 'Unpaid',
        'onlyOverdue': true,
        'page': 1,
        'pageSize': 50,
      });
      expect(page.items.single.paymentStatus, InvoicePaymentStatus.partiallyPaid);
    });

    test('reads one invoice and its PDF through the shared endpoints', () async {
      api.reply = (_) => const FakeReply(_invoiceJson);
      final invoice = okValue(await repository.get('i1'));
      expect(api.last.path, '/api/invoices/i1');
      expect(invoice.lines.single.orders.single.orderNumber, 1042);
      expect(invoice.payments.single.amount, 400);
      expect(invoice.canSettle, isTrue);

      api.reply = (_) => FakeReply(Uint8List.fromList([9]));
      await repository.pdf('i1');
      expect(api.last.path, '/api/invoices/i1/pdf');
    });

    test('collects a counter payment for one invoice', () async {
      api.reply = (_) => const FakeReply(_invoiceJson);
      await repository.collect(
        'i1',
        const CollectDraft(method: PaymentMethod.cash, amount: 500, reference: 'R1'),
      );
      expect(api.last.method, 'POST');
      expect(api.last.path, '/api/admin/invoices/i1/collect');
      expect(api.lastBody, {'method': 'Cash', 'amount': 500, 'reference': 'R1'});
    });

    test('adds up the invoices by product, with where each total comes from', () async {
      api.reply = (_) => const FakeReply({
        'clientId': 't1',
        'clientName': 'Amina',
        'quantity': 150,
        'total': 15000,
        'amountDue': 5000,
        'invoiceCount': 2,
        'products': [
          {
            'productId': 'p1',
            'productName': 'Maths',
            'quantity': 150,
            'total': 15000,
            'amountDue': 5000,
            'invoiceCount': 2,
            'sources': [
              {
                'invoiceId': 'i2',
                'invoiceLabel': 'INV-000002',
                'issueDate': '2026-11-05',
                'dueDate': '2026-11-30',
                'clientId': 't1',
                'clientName': 'Amina',
                'unitPrice': 100,
                'quantity': 50,
                'lineTotal': 5000,
                'amountDue': 5000,
                'paymentStatus': 'Unpaid',
                'orders': [
                  {'orderId': 'o2', 'orderNumber': 1043, 'quantity': 50},
                ],
              },
              {
                'invoiceId': 'i1',
                'invoiceLabel': 'INV-000001',
                'issueDate': '2026-11-04',
                'dueDate': '2026-11-30',
                'clientId': 't1',
                'clientName': 'Amina',
                'unitPrice': 100,
                'quantity': 100,
                'lineTotal': 10000,
                'amountDue': 0,
                'paymentStatus': 'Paid',
                'orders': [
                  {'orderId': 'o1', 'orderNumber': 1042, 'quantity': 100},
                ],
              },
            ],
          },
        ],
      });
      final summary = okValue(
        await repository.byProduct(
          InvoicedProductsFilter(
            clientId: 't1',
            from: DateTime(2026, 11),
            to: DateTime(2026, 11, 30),
            onlyUnpaid: true,
          ),
        ),
      );
      expect(api.last.path, '/api/admin/invoices/by-product');
      expect(api.last.queryParameters, {
        'clientId': 't1',
        'from': '2026-11-01',
        'to': '2026-11-30',
        'onlyUnpaid': true,
      });
      final maths = summary.products.single;
      expect(maths.quantity, 150);
      expect(maths.sources.map((source) => source.quantity), [50, 100]);
      expect(maths.sources.last.paymentStatus, InvoicePaymentStatus.paid);
      expect(maths.sources.first.orders.single.orderNumber, 1043);
    });

    test('a teacher-visible invoice without payment fields reads them as null', () async {
      final json = Map<String, Object?>.of(_invoiceJson)
        ..remove('amountPaid')
        ..remove('amountDue')
        ..remove('paymentStatus')
        ..remove('isOverdue');
      api.reply = (_) => FakeReply(json);
      final invoice = okValue(await repository.get('i1'));
      expect(invoice.summary.amountDue, isNull);
      expect(invoice.summary.paymentStatus, isNull);
      expect(invoice.canSettle, isFalse);
    });

    test('issues from the uninvoiced rows, sending the chosen quantities only', () async {
      api.reply = (_) => const FakeReply([
        {
          'productId': 'p1',
          'productName': 'Maths',
          'unitPrice': 1200,
          'quantity': 5,
          'amount': 6000,
          'orders': [
            {
              'orderId': 'o1',
              'orderNumber': 1042,
              'orderStatus': 'Ready',
              'placedAt': '2026-11-04T10:00:00+00:00',
              'orderLineId': 'l1',
              'quantity': 5,
            },
          ],
        },
      ]);
      final rows = okValue(await repository.uninvoiced('t1'));
      expect(api.last.queryParameters, {'clientId': 't1'});

      api.reply = (_) => const FakeReply(_invoiceJson, status: 201);
      final draft = InvoiceDraft(clientId: 't1', available: rows).setQuantity(rows.single.key, 3);
      await repository.issue(draft);
      expect(api.lastBody, {
        'clientId': 't1',
        'notes': null,
        'lines': [
          {'productId': 'p1', 'unitPrice': 1200, 'quantity': 3},
        ],
      });
    });

    test('voids with a reason and settles an amount or as much as possible', () async {
      await repository.voidInvoice('i1', 'Erreur de quantité');
      expect(api.last.path, '/api/admin/invoices/i1/void');
      expect(api.lastBody, {'reason': 'Erreur de quantité'});

      api.reply = (_) => const FakeReply(_invoiceJson);
      await repository.settle('i1');
      expect(api.lastBody, {'amount': null});
      await repository.settle('i1', amount: 500);
      expect(api.lastBody, {'amount': 500});
    });
  });

  group('DebtRepositoryImpl', () {
    late DebtRepositoryImpl repository;
    setUp(() => repository = DebtRepositoryImpl(api.client));

    test('reads the overview and one teacher\'s items', () async {
      const totals = {
        'clientId': 't1',
        'clientName': 'Amina',
        'overdueInvoices': 1000,
        'upcomingInvoices': 0,
        'openDebts': 3000,
        'overdue': 1000,
        'totalOwed': 4000,
        'walletBalance': 0,
        'oldestDueDate': '2026-10-31',
      };
      api.reply = (_) => FakeReply(paged([totals]));
      final overview = okValue(await repository.overview(const DebtFilter(onlyOwing: false)));
      expect(api.last.queryParameters, {'onlyOwing': false, 'page': 1, 'pageSize': 50});
      expect(overview.items.single.oldestDueDate, DateTime(2026, 10, 31));

      api.reply = (_) => const FakeReply({
        'totals': totals,
        'items': [
          {
            'kind': 'Invoice',
            'id': 'i1',
            'label': 'INV-000001',
            'date': '2026-10-01',
            'dueDate': '2026-10-31',
            'amount': 1000,
            'amountPaid': 0,
            'amountDue': 1000,
            'isOverdue': true,
          },
        ],
      });
      final debts = okValue(await repository.forClient('t1', includeClosed: true));
      expect(api.last.path, '/api/admin/debts/clients/t1');
      expect(api.last.queryParameters, {'includeClosed': true});
      expect(debts.items.single.kind, DebtItemKind.invoice);
    });

    test('creates, settles and writes off', () async {
      api.reply = (_) => const FakeReply(_debtJson, status: 201);
      await repository.create(
        DebtDraft(clientId: 't1', description: ' Ancien ', amount: 3000, dueDate: DateTime(2026, 12)),
      );
      expect(api.lastBody, {
        'clientId': 't1',
        'description': 'Ancien',
        'amount': 3000,
        'dueDate': '2026-12-01',
      });

      await repository.settle('d1', amount: 1000);
      expect(api.last.path, '/api/admin/debts/d1/settle');

      final debt = okValue(await repository.writeOff('d1', 'Geste commercial'));
      expect(api.last.path, '/api/admin/debts/d1/write-off');
      expect(api.lastBody, {'reason': 'Geste commercial'});
      expect(debt.isOpen, isTrue);
    });
  });
}
