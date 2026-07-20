import '../../../core/formatting/money.dart';

enum AccountType {
  checking('CHECKING', 'Conta corrente'),
  savings('SAVINGS', 'Poupanca'),
  wallet('WALLET', 'Carteira'),
  investment('INVESTMENT', 'Investimento'),
  benefits('BENEFITS', 'Beneficios'),
  creditCard('CREDIT_CARD', 'Cartao de credito'),
  other('OTHER', 'Outra');

  const AccountType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AccountType fromApi(String value) {
    return AccountType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => AccountType.other,
    );
  }
}

class Account {
  const Account({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.balanceCents,
    required this.includeInTotal,
    required this.active,
    this.description,
    this.institutionId,
    this.color,
    this.icon,
  });

  final String id;
  final String workspaceId;
  final String name;
  final AccountType type;
  final int balanceCents;
  final bool includeInTotal;
  final bool active;
  final String? description;
  final String? institutionId;
  final String? color;
  final String? icon;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: AccountType.fromApi(json['type'] as String? ?? 'OTHER'),
      balanceCents: Money.parseCents(json['balance']),
      includeInTotal: json['includeInTotal'] as bool? ?? true,
      active: json['active'] as bool? ?? true,
      description: json['description'] as String?,
      institutionId: json['institutionId'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class CreateAccountRequest {
  const CreateAccountRequest({
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.includeInTotal,
    required this.initialBalanceCents,
    this.description,
    this.institutionId,
  });

  final String name;
  final AccountType type;
  final String color;
  final String icon;
  final bool includeInTotal;
  final int initialBalanceCents;
  final String? description;
  final String? institutionId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      'type': type.apiValue,
      if (institutionId != null && institutionId!.isNotEmpty)
        'institutionId': institutionId,
      'color': color,
      'icon': icon,
      'includeInTotal': includeInTotal,
      'initialBalance': Money.centsToDecimal(initialBalanceCents),
    };
  }
}
