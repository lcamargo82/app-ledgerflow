import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class LedgerScaffold extends StatelessWidget {
  const LedgerScaffold({
    required this.children,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.showBrand = true,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget> actions;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            titleSpacing: 16,
            title: showBrand
                ? const _BrandTitle()
                : Text(
                    title ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
            actions: actions,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.outlineVariant),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            sliver: SliverList.list(
              children: [
                if (title != null && showBrand) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.account_balance_wallet, color: AppColors.primary),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineSmall,
            children: const [
              TextSpan(text: 'Ledger'),
              TextSpan(
                text: 'Flow',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
