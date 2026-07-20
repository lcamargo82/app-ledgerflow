import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerflow/src/features/dashboard/domain/dashboard_summary.dart';

void main() {
  test('parses dashboard summary money, categories and accounts', () {
    final summary = DashboardSummary.fromJson({
      'currentBalance': '1240.90',
      'totalIncluded': 1000,
      'totalOverall': '-20.35',
      'expensesByCategory': [
        {
          'categoryId': 'food-id',
          'name': 'Alimentacao',
          'color': '#EF4444',
          'icon': 'utensils',
          'amount': '250.45',
          'percent': 62.5,
        },
      ],
      'accounts': [
        {
          'id': 'account-id',
          'name': 'Conta PJ',
          'type': 'CHECKING',
          'balance': '149.57',
          'includeInTotal': true,
          'color': '#4F46E5',
          'icon': 'bank',
        },
      ],
    });

    expect(summary.currentBalanceCents, 124090);
    expect(summary.totalIncludedCents, 100000);
    expect(summary.totalOverallCents, -2035);
    expect(summary.hasAccounts, isTrue);
    expect(summary.hasExcludedAmount, isTrue);
    expect(summary.expensesByCategory.single.amountCents, 25045);
    expect(summary.expensesByCategory.single.percent, 62.5);
    expect(summary.accounts.single.balanceCents, 14957);
  });

  test('accepts alternate category total and percentage field names', () {
    final summary = DashboardSummary.fromJson({
      'expensesByCategory': [
        {
          'id': 'transport-id',
          'categoryName': 'Transporte',
          'total': '32,50',
          'percentage': '10',
        },
      ],
      'accounts': [],
    });

    expect(summary.expensesByCategory.single.categoryId, 'transport-id');
    expect(summary.expensesByCategory.single.name, 'Transporte');
    expect(summary.expensesByCategory.single.amountCents, 3250);
    expect(summary.expensesByCategory.single.percent, 10);
  });

  test('accepts alternate dashboard summary and category field names', () {
    final summary = DashboardSummary.fromJson({
      'balance': '500.00',
      'includedBalance': '450.00',
      'overallBalance': '650.00',
      'categoryRanking': [
        {
          'id': 'home-id',
          'categoryName': 'Moradia',
          'total': '120.00',
          'percentage': 40,
        },
      ],
    });

    expect(summary.currentBalanceCents, 50000);
    expect(summary.totalIncludedCents, 45000);
    expect(summary.totalOverallCents, 65000);
    expect(summary.expensesByCategory.single.name, 'Moradia');
  });

  test('parses dashboard totalAmount and derives category percentage', () {
    final summary = DashboardSummary.fromJson({
      'expensesByCategory': [
        {
          'categoryId': 'food-id',
          'name': 'Alimentacao',
          'totalAmount': '75.00',
        },
        {'categoryId': 'home-id', 'name': 'Moradia', 'totalAmount': '25.00'},
      ],
    });

    expect(summary.expensesByCategory.first.amountCents, 7500);
    expect(summary.expensesByCategory.first.percent, 75);
    expect(summary.expensesByCategory.last.amountCents, 2500);
    expect(summary.expensesByCategory.last.percent, 25);
  });
}
