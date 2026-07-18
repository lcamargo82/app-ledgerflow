import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LedgerScaffold(
      title: 'Olá, Leandro!',
      subtitle: 'Aqui esta o resumo do seu fluxo financeiro hoje.',
      children: [
        const _BalanceCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/transactions'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Receita'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/transactions'),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Despesa'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _CategoryChartCard(),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Transações recentes',
          actionLabel: 'Ver todas',
          onAction: () => context.go('/transactions'),
        ),
        const SizedBox(height: 8),
        ..._recentTransactions.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TransactionTile(item: item),
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return LfCard(
      color: AppColors.surfaceHigh,
      borderColor: AppColors.emerald.withValues(alpha: .5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SALDO TOTAL', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            'R\$ 12.500,00',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: AppColors.emerald),
              SizedBox(width: 4),
              Text(
                '+2,4% este mes',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChartCard extends StatelessWidget {
  const _CategoryChartCard();

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Despesas por categoria',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 420;
              final chart = SizedBox(
                height: 168,
                width: 168,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 44,
                    sectionsSpace: 2,
                    sections: _categorySlices
                        .map(
                          (slice) => PieChartSectionData(
                            value: slice.percent,
                            color: slice.color,
                            radius: 28,
                            showTitle: false,
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
              final legend = Column(
                children: _categorySlices
                    .map((slice) => _LegendRow(slice: slice))
                    .toList(),
              );

              if (isWide) {
                return Row(
                  children: [
                    chart,
                    const SizedBox(width: 24),
                    Expanded(child: legend),
                  ],
                );
              }

              return Column(
                children: [
                  Center(child: chart),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice});

  final _CategorySlice slice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: slice.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(slice.label)),
          Text('${slice.percent.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final _TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final amountColor = item.amount.isNegative
        ? AppColors.error
        : AppColors.emerald;
    final prefix = item.amount.isNegative ? '-' : '+';

    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.onSurfaceVariant,
            child: Icon(item.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Text(
            '$prefix R\$ ${item.amount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CategorySlice {
  const _CategorySlice(this.label, this.percent, this.color);

  final String label;
  final double percent;
  final Color color;
}

class _TransactionItem {
  const _TransactionItem(this.title, this.subtitle, this.amount, this.icon);

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
}

const _categorySlices = [
  _CategorySlice('Moradia', 30, AppColors.primaryContainer),
  _CategorySlice('Alimentação', 30, AppColors.blue),
  _CategorySlice('Transporte', 25, AppColors.cyan),
  _CategorySlice('Lazer', 15, AppColors.emerald),
];

const _recentTransactions = [
  _TransactionItem(
    'Supermercado',
    'Hoje, 14:30',
    -248.9,
    Icons.shopping_cart_outlined,
  ),
  _TransactionItem('Salário', 'Ontem, 08:00', 6200, Icons.payments_outlined),
  _TransactionItem('Uber', 'Ontem, 22:16', -32.5, Icons.local_taxi_outlined),
];
