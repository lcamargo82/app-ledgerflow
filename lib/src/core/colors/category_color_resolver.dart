import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/dashboard/domain/dashboard_summary.dart';

class CategoryColorResolver {
  const CategoryColorResolver._();

  static const _apiFallbackColor = '#64748B';
  static const _fallbackPalette = [
    AppColors.primaryContainer,
    AppColors.blue,
    AppColors.cyan,
    AppColors.emerald,
    AppColors.amber,
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  static Color forExpense(
    ExpenseByCategory expense,
    List<ExpenseByCategory> allExpenses,
  ) {
    final color = _colorFromHex(expense.color);

    if (color != null && !_shouldUseFallbackPalette(allExpenses)) {
      return color;
    }

    final index = allExpenses.indexWhere(
      (candidate) => candidate.categoryId == expense.categoryId,
    );

    return _fallbackPalette[(index < 0 ? 0 : index) % _fallbackPalette.length];
  }

  static bool _shouldUseFallbackPalette(List<ExpenseByCategory> expenses) {
    final colors = expenses
        .map((expense) => expense.color.toUpperCase())
        .where((color) => color.isNotEmpty)
        .toSet();

    return colors.isEmpty ||
        colors.length == 1 && colors.single == _apiFallbackColor;
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      return null;
    }

    return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
  }
}
