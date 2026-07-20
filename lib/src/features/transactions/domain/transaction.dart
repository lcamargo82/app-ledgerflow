import '../../../core/formatting/money.dart';

enum TransactionType {
  income('INCOME', 'Receita'),
  expense('EXPENSE', 'Despesa');

  const TransactionType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TransactionType fromApi(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => TransactionType.expense,
    );
  }
}

enum TransactionOrigin {
  manual('MANUAL'),
  initialBalance('INITIAL_BALANCE');

  const TransactionOrigin(this.apiValue);

  final String apiValue;

  static TransactionOrigin fromApi(String value) {
    return TransactionOrigin.values.firstWhere(
      (origin) => origin.apiValue == value,
      orElse: () => TransactionOrigin.manual,
    );
  }
}

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.workspaceId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.origin,
    required this.amountCents,
    required this.occurredAt,
    required this.description,
  });

  final String id;
  final String workspaceId;
  final String accountId;
  final String categoryId;
  final TransactionType type;
  final TransactionOrigin origin;
  final int amountCents;
  final DateTime occurredAt;
  final String description;

  int get signedAmountCents {
    return type == TransactionType.expense ? -amountCents : amountCents;
  }

  bool get isSystemGenerated => origin == TransactionOrigin.initialBalance;

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    return LedgerTransaction(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      type: TransactionType.fromApi(json['type'] as String? ?? 'EXPENSE'),
      origin: TransactionOrigin.fromApi(json['origin'] as String? ?? 'MANUAL'),
      amountCents: Money.parseCents(json['amount']),
      occurredAt:
          DateTime.tryParse(json['occurredAt'] as String? ?? '') ??
          DateTime.now(),
      description: json['description'] as String? ?? '',
    );
  }
}

class TransactionPage {
  const TransactionPage({
    required this.data,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  final List<LedgerTransaction> data;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final data = json['data'];

    return TransactionPage(
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(LedgerTransaction.fromJson)
                .toList()
          : const [],
      page: meta['page'] as int? ?? 1,
      perPage: meta['perPage'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      totalPages: meta['totalPages'] as int? ?? 1,
    );
  }
}

class MonthlySummary {
  const MonthlySummary({
    required this.currentBalanceCents,
    required this.monthlyBalanceCents,
    required this.totalIncomesCents,
    required this.totalExpensesCents,
  });

  final int currentBalanceCents;
  final int monthlyBalanceCents;
  final int totalIncomesCents;
  final int totalExpensesCents;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      currentBalanceCents: Money.parseCents(json['currentBalance']),
      monthlyBalanceCents: Money.parseCents(json['monthlyBalance']),
      totalIncomesCents: Money.parseCents(json['totalIncomes']),
      totalExpensesCents: Money.parseCents(json['totalExpenses']),
    );
  }
}

class CreateTransactionRequest {
  const CreateTransactionRequest({
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amountCents,
    required this.occurredAt,
    required this.description,
  });

  final String accountId;
  final String categoryId;
  final TransactionType type;
  final int amountCents;
  final DateTime occurredAt;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type.apiValue,
      'amount': Money.centsToDecimal(amountCents),
      'occurredAt': occurredAt.toUtc().toIso8601String(),
      'description': description,
    };
  }
}
