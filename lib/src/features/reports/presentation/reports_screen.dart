import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/money.dart';
import '../../../core/icons/ledger_icon_mapper.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../dashboard/domain/dashboard_summary.dart';
import '../../transactions/domain/transaction.dart';
import 'controllers/reports_controller.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportsControllerProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(reportsControllerProvider);
    final summary = controller.monthlySummary;
    final dashboard = controller.dashboardSummary;

    return LedgerScaffold(
      title: 'Relatorios',
      subtitle: 'Compare entradas, saidas e categorias do mes.',
      children: [
        _PeriodSelector(
          label: controller.period.label,
          onPrevious: controller.isLoading
              ? null
              : () => ref.read(reportsControllerProvider).previousPeriod(),
          onNext: controller.isLoading
              ? null
              : () => ref.read(reportsControllerProvider).nextPeriod(),
        ),
        const SizedBox(height: 16),
        if (controller.isLoading)
          const _LoadingState()
        else if (controller.errorMessage != null)
          _ErrorState(
            message: controller.errorMessage!,
            onRetry: () => ref.read(reportsControllerProvider).load(),
          )
        else if (summary == null || dashboard == null)
          const _EmptyReportsState()
        else ...[
          _SummaryGrid(summary: summary),
          const SizedBox(height: 24),
          _MonthlyBars(summary: summary),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Categorias de maior impacto'),
          const SizedBox(height: 8),
          if (dashboard.expensesByCategory.isEmpty)
            const _EmptyCategoryRanking()
          else
            ...dashboard.expensesByCategory.map(
              (expense) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CategoryRankTile(expense: expense),
              ),
            ),
        ],
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Mes anterior',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Proximo mes',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 4 : 2;
        final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: width,
              label: 'Saldo atual',
              value: summary.currentBalanceCents,
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
            ),
            _SummaryCard(
              width: width,
              label: 'Saldo mensal',
              value: summary.monthlyBalanceCents,
              icon: Icons.compare_arrows_outlined,
              color: summary.monthlyBalanceCents < 0
                  ? AppColors.error
                  : AppColors.emerald,
            ),
            _SummaryCard(
              width: width,
              label: 'Receitas',
              value: summary.totalIncomesCents,
              icon: Icons.trending_up,
              color: AppColors.emerald,
            ),
            _SummaryCard(
              width: width,
              label: 'Despesas',
              value: summary.totalExpensesCents,
              icon: Icons.trending_down,
              color: AppColors.error,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LfCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Money.formatCents(value),
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final income = summary.totalIncomesCents.abs() / 100;
    final expense = summary.totalExpensesCents.abs() / 100;
    final maxY = [income, expense, 100.0].reduce((a, b) => a > b ? a : b) * 1.2;

    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receitas vs despesas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ChartLegend(label: 'Receitas', color: AppColors.emerald),
              const SizedBox(width: 16),
              _ChartLegend(
                label: 'Despesas',
                color: AppColors.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Receitas', 'Despesas'];
                        final index = value.toInt();

                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[index]),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _BarGroup.item(0, income, AppColors.emerald),
                  _BarGroup.item(1, expense, AppColors.primaryContainer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _CategoryRankTile extends StatelessWidget {
  const _CategoryRankTile({required this.expense});

  final ExpenseByCategory expense;

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(expense.color) ?? AppColors.primaryContainer;
    final progress = (expense.percent / 100).clamp(0.0, 1.0);

    return LfCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Icon(LedgerIconMapper.fromKey(expense.icon)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.percent.toStringAsFixed(0)}% das despesas',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              Text(
                Money.formatCents(expense.amountCents),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppColors.surfaceHigh,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategoryRanking extends StatelessWidget {
  const _EmptyCategoryRanking();

  @override
  Widget build(BuildContext context) {
    return const LfCard(
      child: Column(
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 40,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 12),
          Text('Sem despesas categorizadas neste periodo.'),
        ],
      ),
    );
  }
}

class _EmptyReportsState extends StatelessWidget {
  const _EmptyReportsState();

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.insert_chart_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sem dados para o periodo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Lance receitas e despesas para acompanhar seus relatorios.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _BarGroup {
  const _BarGroup._();

  static BarChartGroupData item(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 36,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ],
    );
  }
}

Color? _colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return null;
  }

  return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
}
