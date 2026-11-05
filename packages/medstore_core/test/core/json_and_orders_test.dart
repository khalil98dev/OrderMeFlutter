import 'package:flutter_test/flutter_test.dart';
import 'package:medstore_core/medstore_core.dart';

void main() {
  group('JsonMap', () {
    const raw = {
      'name': 'Amina',
      'total': 45000.0,
      'count': 3,
      'dueDate': '2026-11-30',
      'placedAt': '2026-11-04T20:34:56.35+01:00',
      'fields': {'Price': 'Read'},
    };
    final json = JsonMap.of(raw);

    test('a missing key is null (the API leaves nulls and hidden fields out)', () {
      expect(json.stringOrNull('phone'), isNull);
      expect(json.moneyOrNull('amountDue'), isNull);
      expect(json.dayOrNull('oldestDueDate'), isNull);
      expect(json.list('lines', (item) => item), isEmpty);
    });

    test('a missing required key throws, so a shape mismatch is not silent', () {
      expect(() => json.string('phone'), throwsA(isA<TypeError>()));
    });

    test('days are local dates; instants are UTC', () {
      expect(json.day('dueDate'), DateTime(2026, 11, 30));
      expect(json.instant('placedAt'), DateTime.utc(2026, 11, 4, 19, 34, 56, 350));
      expect(json.integer('count'), 3);
      expect(json.money('total'), 45000);
      expect(json.stringMap('fields'), {'Price': 'Read'});
    });

    test('apiDay writes "yyyy-MM-dd"', () {
      expect(apiDay(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('OrderModel', () {
    test('reads an order with its lines and timeline', () {
      final order = OrderModel.fromJson({
        'id': 'o1',
        'number': 1042,
        'clientId': 't1',
        'status': 'InPreparation',
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
          {'status': 'Pending', 'changedAt': '2026-11-04T10:00:00+00:00', 'actor': 'Client'},
          {
            'status': 'InPreparation',
            'changedAt': '2026-11-04T11:00:00+00:00',
            'actor': 'Staff',
            'changedByName': 'admin',
          },
        ],
      });

      expect(order.status, OrderStatus.inPreparation);
      expect(order.clientName, isNull);
      expect(order.lines.single.quantity, 2);
      expect(order.history.map((step) => step.actor), [OrderActor.client, OrderActor.staff]);
    });

    test('an unknown status from a newer server reads as pending instead of failing', () {
      expect(OrderStatus.fromApi('OnHold'), OrderStatus.pending);
    });
  });

  test('PaymentTerms: a hidden value stays null', () {
    expect(PaymentTerms.fromApiOrNull(null), isNull);
    expect(PaymentTerms.fromApiOrNull('EndOfYear'), PaymentTerms.endOfYear);
  });
}
