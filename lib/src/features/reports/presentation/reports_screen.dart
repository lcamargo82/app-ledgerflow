import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LedgerScaffold(
      title: 'Relatórios',
      subtitle: 'Compare entradas, saidas e orcamentos do mes.',
      children: const [
        _MonthlyBars(),
        SizedBox(height: 24),
        SectionHeader(title: 'Orçamentos'),
        SizedBox(height: 8),
        _BudgetProgress(label: 'Alimentação', current: 1120, target: 1400),
        SizedBox(height: 8),
        _BudgetProgress(label: 'Transporte', current: 680, target: 700),
        SizedBox(height: 8),
        _BudgetProgress(label: 'Lazer', current: 920, target: 800),
      ],
    );
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars();

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receitas vs despesas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Abr', 'Mai', 'Jun', 'Jul'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[value.toInt()]),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _BarGroup.month(0, 6.2, 3.8),
                  _BarGroup.month(1, 6.6, 4.1),
                  _BarGroup.month(2, 7.1, 4.7),
                  _BarGroup.month(3, 7.6, 4.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({
    required this.label,
    required this.current,
    required this.target,
  });

  final String label;
  final double current;
  final double target;

  @override
  Widget build(BuildContext context) {
    final progress = current / target;
    final overBudget = progress > 1;
    final color = overBudget ? AppColors.error : AppColors.cyan;

    return LfCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.clamp(0, 1),
              backgroundColor: AppColors.surfaceHigh,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${current.toStringAsFixed(0)} de R\$ ${target.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _BarGroup {
  const _BarGroup._();

  static BarChartGroupData month(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barsSpace: 6,
      barRods: [
        BarChartRodData(
          toY: income,
          width: 12,
          borderRadius: BorderRadius.circular(4),
          color: AppColors.emerald,
        ),
        BarChartRodData(
          toY: expense,
          width: 12,
          borderRadius: BorderRadius.circular(4),
          color: AppColors.primaryContainer,
        ),
      ],
    );
  }
}
