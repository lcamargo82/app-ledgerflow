import '../../../core/formatting/money.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.currentBalanceCents,
    required this.totalIncludedCents,
    required this.totalOverallCents,
    required this.expensesByCategory,
    required this.accounts,
  });

  final int currentBalanceCents;
  final int totalIncludedCents;
  final int totalOverallCents;
  final List<ExpenseByCategory> expensesByCategory;
  final List<DashboardAccount> accounts;

  bool get hasAccounts => accounts.isNotEmpty;
  bool get hasExcludedAmount => totalIncludedCents != totalOverallCents;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final expenses = json['expensesByCategory'];
    final accounts = json['accounts'];

    return DashboardSummary(
      currentBalanceCents: Money.parseCents(json['currentBalance']),
      totalIncludedCents: Money.parseCents(json['totalIncluded']),
      totalOverallCents: Money.parseCents(json['totalOverall']),
      expensesByCategory: expenses is List
          ? expenses
                .whereType<Map<String, dynamic>>()
                .map(ExpenseByCategory.fromJson)
                .toList()
          : const [],
      accounts: accounts is List
          ? accounts
                .whereType<Map<String, dynamic>>()
                .map(DashboardAccount.fromJson)
                .toList()
          : const [],
    );
  }
}

class ExpenseByCategory {
  const ExpenseByCategory({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.amountCents,
    required this.percent,
  });

  final String categoryId;
  final String name;
  final String color;
  final String icon;
  final int amountCents;
  final double percent;

  factory ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategory(
      categoryId: _readString(json, ['categoryId', 'id']),
      name: _readString(json, ['name', 'categoryName'], fallback: 'Categoria'),
      color: _readString(json, ['color'], fallback: '#64748B'),
      icon: _readString(json, ['icon'], fallback: 'tag'),
      amountCents: Money.parseCents(_readFirst(json, ['amount', 'total'])),
      percent: _readDouble(json, ['percent', 'percentage']),
    );
  }
}

class DashboardAccount {
  const DashboardAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
    required this.includeInTotal,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String type;
  final int balanceCents;
  final bool includeInTotal;
  final String color;
  final String icon;

  factory DashboardAccount.fromJson(Map<String, dynamic> json) {
    return DashboardAccount(
      id: _readString(json, ['id']),
      name: _readString(json, ['name'], fallback: 'Conta'),
      type: _readString(json, ['type'], fallback: 'OTHER'),
      balanceCents: Money.parseCents(json['balance']),
      includeInTotal: json['includeInTotal'] as bool? ?? true,
      color: _readString(json, ['color'], fallback: '#4F46E5'),
      icon: _readString(json, ['icon'], fallback: 'bank'),
    );
  }
}

Object? _readFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }

  return null;
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  final value = _readFirst(json, keys);

  if (value == null) {
    return fallback;
  }

  return value.toString();
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  final value = _readFirst(json, keys);

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}
