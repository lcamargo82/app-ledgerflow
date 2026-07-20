import 'package:flutter/material.dart';

class LedgerIconMapper {
  const LedgerIconMapper._();

  static IconData fromKey(String? key) {
    return switch (key) {
      'bank' => Icons.account_balance_outlined,
      'wallet' => Icons.account_balance_wallet_outlined,
      'card' => Icons.credit_card,
      'cash' => Icons.payments_outlined,
      'investment' => Icons.trending_up,
      'utensils' => Icons.restaurant_outlined,
      'food' => Icons.restaurant_outlined,
      'home' => Icons.home_outlined,
      'transport' => Icons.directions_car_outlined,
      'car' => Icons.directions_car_outlined,
      'health' => Icons.health_and_safety_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'education' => Icons.school_outlined,
      'salary' => Icons.work_outline,
      'gift' => Icons.card_giftcard_outlined,
      'tag' => Icons.sell_outlined,
      _ => Icons.category_outlined,
    };
  }
}
