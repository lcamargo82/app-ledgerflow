class WorkspaceSummary {
  const WorkspaceSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.active,
  });

  final String id;
  final String name;
  final String type;
  final String currency;
  final bool active;

  factory WorkspaceSummary.fromJson(Map<String, dynamic> json) {
    return WorkspaceSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      currency: json['currency'] as String? ?? 'BRL',
      active: json['active'] as bool? ?? true,
    );
  }
}
