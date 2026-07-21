import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerflow/src/features/transactions/domain/transaction.dart';

void main() {
  group('LedgerTransaction', () {
    test('parses transfer with destination account', () {
      final transaction = LedgerTransaction.fromJson({
        'id': 'transaction-1',
        'workspaceId': 'workspace-1',
        'accountId': 'origin-account',
        'destinationAccountId': 'destination-account',
        'categoryId': null,
        'type': 'TRANSFER',
        'origin': 'MANUAL',
        'amount': '125.40',
        'occurredAt': '2026-07-21T12:00:00.000Z',
        'description': 'Reserva',
        'destinationAccount': {
          'id': 'destination-account',
          'name': 'Poupanca',
          'type': 'SAVINGS',
          'color': '#4F46E5',
          'icon': 'piggy-bank',
        },
      });

      expect(transaction.type, TransactionType.transfer);
      expect(transaction.categoryId, isNull);
      expect(transaction.destinationAccountId, 'destination-account');
      expect(transaction.destinationAccount?.name, 'Poupanca');
      expect(transaction.amountCents, 12540);
      expect(transaction.signedAmountCents, 12540);
    });

    test('keeps unknown transaction type fallback as expense', () {
      expect(TransactionType.fromApi('UNKNOWN'), TransactionType.expense);
    });
  });

  group('CreateTransactionRequest', () {
    test('serializes transfer without category', () {
      final request = CreateTransactionRequest(
        accountId: 'origin-account',
        destinationAccountId: 'destination-account',
        type: TransactionType.transfer,
        amountCents: 9900,
        occurredAt: DateTime.utc(2026, 7, 21, 12),
        description: 'Transferencia entre contas',
      );

      expect(request.toJson(), {
        'accountId': 'origin-account',
        'destinationAccountId': 'destination-account',
        'type': 'TRANSFER',
        'amount': 99.0,
        'occurredAt': '2026-07-21T12:00:00.000Z',
        'description': 'Transferencia entre contas',
      });
    });

    test(
      'serializes expense with category and without destination account',
      () {
        final request = CreateTransactionRequest(
          accountId: 'account-1',
          categoryId: 'category-1',
          type: TransactionType.expense,
          amountCents: 4590,
          occurredAt: DateTime.utc(2026, 7, 21, 12),
          description: 'Mercado',
        );

        expect(request.toJson(), {
          'accountId': 'account-1',
          'categoryId': 'category-1',
          'type': 'EXPENSE',
          'amount': 45.9,
          'occurredAt': '2026-07-21T12:00:00.000Z',
          'description': 'Mercado',
        });
      },
    );
  });
}
