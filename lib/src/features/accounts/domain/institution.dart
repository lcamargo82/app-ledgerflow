class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.icon,
    required this.active,
    this.compeCode,
    this.ispb,
  });

  final String id;
  final String name;
  final String shortName;
  final String type;
  final String icon;
  final bool active;
  final String? compeCode;
  final String? ispb;

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      type: json['type'] as String? ?? 'OTHER',
      icon: json['icon'] as String? ?? 'bank',
      active: json['active'] as bool? ?? true,
      compeCode: json['compeCode'] as String?,
      ispb: json['ispb'] as String?,
    );
  }
}
