import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class LfCard extends StatelessWidget {
  const LfCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surfaceContainer,
    this.borderColor = AppColors.outlineVariant,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
