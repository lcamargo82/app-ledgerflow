enum CategoryType {
  income('INCOME', 'Receitas'),
  expense('EXPENSE', 'Despesas'),
  adjustment('ADJUSTMENT', 'Ajustes');

  const CategoryType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CategoryType fromApi(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => CategoryType.expense,
    );
  }
}

class Category {
  const Category({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.isSystemDefault,
    required this.active,
  });

  final String id;
  final String workspaceId;
  final String name;
  final CategoryType type;
  final String color;
  final String icon;
  final bool isSystemDefault;
  final bool active;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: CategoryType.fromApi(json['type'] as String? ?? 'EXPENSE'),
      color: json['color'] as String? ?? '#64748B',
      icon: json['icon'] as String? ?? 'tag',
      isSystemDefault: json['isSystemDefault'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
    );
  }
}

class CreateCategoryRequest {
  const CreateCategoryRequest({
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
  });

  final String name;
  final CategoryType type;
  final String color;
  final String icon;

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type.apiValue, 'color': color, 'icon': icon};
  }
}
